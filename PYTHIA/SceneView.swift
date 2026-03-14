// SceneView.swift
// PYTHIA
//
// The primary game view. Renders the current scene background,
// the dialogue text panel at the bottom, speaker names, and
// player choices. Hands off to VisionView when the engine
// fires a vision session trigger.
//
// The aesthetic is the GDD's "carved stone, worn papyrus" UI —
// serif typography, warm ochre/terracotta palette, no floating
// modern elements. Everything feels like it belongs in 480 BC.
//
// Usage:
//   SceneView (engine: engine)

import SwiftUI

// MARK: - SceneView

struct SceneView: View {
    @ObservedObject var engine: NarrativeEngine

    // MARK: Local state

    @State private var textVisible: Bool = false        // Fades in with each new node
    @State private var showingJournal: Bool = false
    @State private var tapIndicatorOpacity: Double = 1  // Pulsing "tap to continue"
    @State private var showingActTitle: Bool = false    // Act transition title card
    @State private var showingEndGame: Bool = false     // End game / credits screen
    @State private var isActTransitionPending: Bool = false  // Blocks tap while title card is queued/shown

    var onNewGame: (() -> Void)? = nil                  // Called when player restarts

    // MARK: Palette — warm ochre / parchment world

    private let parchment     = Color (red: 0.96, green: 0.91, blue: 0.82)   // #F5E8D0
    private let ochre         = Color (red: 0.72, green: 0.52, blue: 0.28)   // warm mid
    private let deepOchre     = Color (red: 0.45, green: 0.30, blue: 0.15)   // shadow
    private let terracotta    = Color (red: 0.65, green: 0.32, blue: 0.20)
    private let stoneGrey     = Color (red: 0.30, green: 0.27, blue: 0.22)
    private let panelBG       = Color (red: 0.14, green: 0.11, blue: 0.08)   // near-black stone
    private let panelBorder   = Color (red: 0.45, green: 0.35, blue: 0.22)

    // MARK: Body

    var body: some View {
        ZStack (alignment: .bottom) {
            // --- Scene background ---
            sceneBackground

            // --- Vignette overlay ---
            vignette

            // --- Journal button (top right) ---
            VStack {
                HStack {
                    Spacer ()
                    journalButton
                        .padding (.top, 56)
                        .padding (.trailing, 24)
                }
                Spacer ()
            }

            // --- Dialogue panel ---
            if let node = engine.currentNode {
                dialoguePanel (node: node)
                    .transition (.move (edge: .bottom).combined (with: .opacity))
            }
        }
        .ignoresSafeArea ()
        // Desaturation fade before vision sessions
        .saturation(engine.pendingVisionSession != nil ? 0.0 : 1.0)
        .animation (.easeInOut (duration: 1.2), value: engine.pendingVisionSession == nil)
        // Handoff to VisionView
        .fullScreenCover (
            isPresented: Binding (
                get: { engine.pendingVisionSession != nil },
                set: { _ in }
            )
        ) {
            if let session = engine.pendingVisionSession {
                VisionView (fragments: session.fragments) { selectedIDs in
                    // Dismiss the cover first, then advance
                    DispatchQueue.main.asyncAfter (deadline: .now () + 0.5) {
                        engine.visionSessionCompleted (
                            sessionID: session.sessionID,
                            selectedFragmentIDs: selectedIDs
                        )
                    }
                }
            }
        }
        // Journal sheet
        .sheet (isPresented: $showingJournal) {
            JournalView (entries: engine.journalEntries)
        }
        // End game screen
        .fullScreenCover (isPresented: $showingEndGame) {
            EndGameView (
                ending: engine.resolvedEnding,
                onPlayAgain: {
                    showingEndGame = false
                    onNewGame? ()
                }
            )
        }
        // Act title card
        .fullScreenCover (isPresented: $showingActTitle) {
            ActTitleCard (actNumber: engine.currentActNumber) {
                isActTransitionPending = false
                showingActTitle = false
            }
        }
        // Reset text fade on node change
        .onChange (of: engine.currentNode?.id) {
            textVisible = false
            withAnimation (.easeIn (duration: 0.5).delay (0.15)) {
                textVisible = true
            }
            
            // Route to ending
            if engine.currentNode?.id == "epilogue_ending_branch" {
                engine.routeToEnding ()
            }

            // Trigger end game screen
            if engine.currentNode?.id == "epilogue_end" {
                DispatchQueue.main.asyncAfter (deadline: .now () + 2.5) {
                    showingEndGame = true
                }
            }
        }
        // Show act title card on act transition — suppressed during continue load
        .onChange (of: engine.currentActNumber) {
            if engine.currentActNumber > 1, !engine.isLoadingGame {
                isActTransitionPending = true
                DispatchQueue.main.asyncAfter (deadline: .now () + 1.5) {
                    showingActTitle = true
                }
            }
        }
        .onAppear {
            withAnimation (.easeIn (duration: 0.6)) {
                textVisible = true
            }
            startTapIndicatorPulse ()
        }
    }

    // MARK: - Background

    /// Scene background — placeholder colour fields per location.
    /// Replace with actual illustrated assets when art is ready.
    private var sceneBackground: some View {
        ZStack {
            // Background image for current location
            Image ("bg_\(engine.currentLocation.rawValue)")
                .resizable ()
                .scaledToFill ()
                .ignoresSafeArea ()
                .animation (.easeInOut (duration: 1.0), value: engine.currentLocation)

            // Atmospheric gradient overlay — darkens bottom behind dialogue panel
            LinearGradient (
                colors: [
                    Color.black.opacity (0.0),
                    Color.black.opacity (0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea ()
        }
    }

    /// Soft vignette around the screen edges — focuses attention inward
    private var vignette: some View {
        RadialGradient (
            colors: [Color.clear, Color.black.opacity (0.55)],
            center: .center,
            startRadius: 180,
            endRadius: 420
        )
        .ignoresSafeArea ()
        .allowsHitTesting (false)
    }

    // MARK: - Dialogue Panel

    private func dialoguePanel (node: DialogueNode) -> some View {
        VStack (alignment: .leading, spacing: 0) {
            Color.clear.frame (height: 20)
            
            // Speaker row — portrait + name, only shown when not narrator
            if let speaker = node.speaker, speaker != .narrator {
                HStack (spacing: 12) {
                    // Portrait — only for characters with art
                    if let portraitName = speaker.portraitAssetName {
                        Image (portraitName)
                            .resizable ()
                            .scaledToFill ()
                            .frame (width: 44, height: 44)
                            .clipShape (RoundedRectangle (cornerRadius: 3))
                            .overlay (
                                RoundedRectangle (cornerRadius: 3)
                                    .stroke (speaker.accentColor.opacity (0.5), lineWidth: 0.8)
                            )
                    }

                    Text (speaker.displayName)
                        .font (.system (size: 10, weight: .semibold, design: .serif))
                        .tracking (4)
                        .foregroundColor (speaker.accentColor)
                }
                .padding (.horizontal, 24)
                .padding (.top, 20)
                .padding (.bottom, 8)
            }

            // Divider line — thin, stone-coloured
            if node.speaker != nil && node.speaker != .narrator {
                Rectangle ()
                    .fill (panelBorder.opacity (0.4))
                    .frame (height: 0.5)
                    .padding (.horizontal, 24)
                    .padding (.bottom, 14)
            }

            // Dialogue text
            Text (node.text)
                .font (.system (size: 16, weight: .light, design: .serif))
                .foregroundColor (parchment.opacity (0.92))
                .lineSpacing (7)
                .padding (.horizontal, 24)
                .opacity (textVisible ? 1 : 0)

            // Choices OR tap-to-continue indicator
            if let choices = node.choices, !choices.isEmpty {
                choiceButtons (choices: engine.availableChoices (for: node))
                    .padding (.top, 18)
                    .padding (.bottom, 28)
            } else {
                tapToContinueIndicator
                    .padding (.top, 12)
                    .padding (.bottom, 24)
            }
        }
        .background (
            // Stone panel with subtle texture
            ZStack {
                panelBG
                // Subtle top border in ochre
                VStack {
                    Rectangle ()
                        .fill (panelBorder.opacity (0.6))
                        .frame (height: 1)
                    Spacer ()
                }
            }
        )
        .onTapGesture {
            if node.choices == nil, !isActTransitionPending {
                engine.tapAdvance ()
            }
        }
    }

    // MARK: - Choice Buttons

    private func choiceButtons (choices: [DialogueChoice]) -> some View {
        VStack (alignment: .leading, spacing: 2) {
            ForEach (choices) { choice in
                Button {
                    engine.selectChoice (choice)
                } label: {
                    HStack (alignment: .top, spacing: 12) {
                        // Greek chevron marker
                        Text ("›")
                            .font (.system (size: 16, weight: .light, design: .serif))
                            .foregroundColor (ochre.opacity (0.7))

                        Text (choice.text)
                            .font (.system (size: 14, weight: .light, design: .serif))
                            .foregroundColor (parchment.opacity (0.80))
                            .lineSpacing (5)
                            .multilineTextAlignment (.leading)
                    }
                    .padding (.horizontal, 24)
                    .padding (.vertical, 10)
                    .frame (maxWidth: .infinity, alignment: .leading)
                    .contentShape (Rectangle ())
                }
                .buttonStyle (ChoiceButtonStyle (borderColor: panelBorder, ochre: ochre))

                if choice.id != choices.last?.id {
                    Rectangle ()
                        .fill (panelBorder.opacity (0.2))
                        .frame (height: 0.5)
                        .padding (.horizontal, 24)
                }
            }
        }
    }

    // MARK: - Tap Indicator

    private var tapToContinueIndicator: some View {
        HStack {
            Spacer ()
            Text ("· · ·")
                .font (.system (size: 12, weight: .ultraLight, design: .serif))
                .foregroundColor (ochre.opacity (tapIndicatorOpacity * 0.6))
                .tracking (4)
            Spacer ()
        }
    }

    private func startTapIndicatorPulse () {
        withAnimation (.easeInOut (duration: 1.4).repeatForever (autoreverses: true)) {
            tapIndicatorOpacity = 0.3
        }
    }

    // MARK: - Journal Button

    private var journalButton: some View {
        Button {
            showingJournal = true
        } label: {
            Image (systemName: "book")
                .font (.system (size: 16, weight: .ultraLight))
                .foregroundColor (parchment.opacity (0.5))
                .padding (10)
                .background (
                    Circle ()
                        .fill (panelBG.opacity (0.6))
                        .overlay (
                            Circle ()
                                .stroke (panelBorder.opacity (0.4), lineWidth: 0.5)
                        )
                )
        }
        .opacity (engine.journalEntries.isEmpty ? 0 : 1)
        .animation (.easeInOut, value: engine.journalEntries.isEmpty)
    }
}

// MARK: - Choice Button Style

struct ChoiceButtonStyle: ButtonStyle {
    let borderColor: Color
    let ochre: Color

    func makeBody (configuration: Configuration) -> some View {
        configuration.label
            .background (
                configuration.isPressed
                    ? ochre.opacity (0.08)
                    : Color.clear
            )
            .animation (.easeOut (duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - JournalView

/// Simple journal sheet — lists entries the player has accumulated.
/// Styled as worn papyrus / wax tablet.
struct JournalView: View {
    let entries: [JournalEntry]
    @Environment(\.dismiss) private var dismiss

    private let parchment  = Color (red: 0.96, green: 0.91, blue: 0.82)
    private let deepOchre  = Color (red: 0.45, green: 0.30, blue: 0.15)
    private let bgColor    = Color (red: 0.18, green: 0.14, blue: 0.09)

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea ()

            VStack (spacing: 0) {

                // Header
                HStack {
                    Text ("MARA'S WRITINGS")
                        .font (.system (size: 11, weight: .light, design: .serif))
                        .tracking (5)
                        .foregroundColor (parchment.opacity (0.5))
                    Spacer ()
                    Button {
                        dismiss ()
                    } label: {
                        Image (systemName: "xmark")
                            .font (.system (size: 13, weight: .ultraLight))
                            .foregroundColor (parchment.opacity (0.4))
                    }
                }
                .padding (.horizontal, 28)
                .padding (.top, 48)
                .padding (.bottom, 24)

                Rectangle ()
                    .fill (deepOchre.opacity (0.3))
                    .frame (height: 0.5)

                if entries.isEmpty {
                    Spacer ()
                    Text ("Nothing has been written yet.")
                        .font (.system (size: 14, weight: .ultraLight, design: .serif))
                        .foregroundColor (parchment.opacity (0.3))
                        .italic ()
                    Spacer ()
                } else {
                    ScrollView {
                        VStack (alignment: .leading, spacing: 32) {
                            ForEach (entries) { entry in
                                VStack (alignment: .leading, spacing: 10) {
                                    Text (entry.title)
                                        .font (.system (size: 11, weight: .semibold, design: .serif))
                                        .tracking (3)
                                        .foregroundColor (deepOchre.opacity (0.9))

                                    Text (entry.body)
                                        .font (.system (size: 15, weight: .light, design: .serif))
                                        .foregroundColor (parchment.opacity (0.75))
                                        .lineSpacing (7)
                                }
                                .padding (.horizontal, 28)
                            }
                        }
                        .padding (.top, 28)
                        .padding (.bottom, 48)
                    }
                }
            }
        }
    }
}

// MARK: - Act Title Card

/// Full-screen chapter break — shown between acts.
/// Styled as darkness with gold lettering — deliberate, weighty.
struct ActTitleCard: View {
    let actNumber: Int
    let onDismiss: () -> Void

    @State private var visible: Bool = false

    private let parchment = Color (red: 0.96, green: 0.91, blue: 0.82)
    private let ochre     = Color (red: 0.72, green: 0.52, blue: 0.28)

    private var actTitle: String {
        switch actNumber {
        case 1: return "THE VOICE"
        case 2: return "THE DELEGATIONS"
        case 3: return "THE PASS"
        case 4: return "THE SILENCE"
        default: return ""
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea ()

            VStack (spacing: 20) {
                Text ("— ACT \(romanNumeral (for: actNumber)) —")
                    .font (.system (size: 11, weight: .light, design: .serif))
                    .tracking (6)
                    .foregroundColor (ochre.opacity (0.7))

                Text (actTitle)
                    .font (.system (size: 22, weight: .ultraLight, design: .serif))
                    .tracking (8)
                    .foregroundColor (parchment.opacity (0.85))

                Rectangle ()
                    .fill (ochre.opacity (0.3))
                    .frame (width: 60, height: 0.5)
                    .padding (.top, 8)
            }
            .opacity (visible ? 1 : 0)
            .animation (.easeIn (duration: 1.2), value: visible)

            // Tap anywhere to continue
            VStack {
                Spacer ()
                Text ("tap to continue")
                    .font (.system (size: 10, weight: .ultraLight, design: .serif))
                    .tracking (3)
                    .foregroundColor (parchment.opacity (visible ? 0.3 : 0))
                    .animation (.easeIn (duration: 1.2).delay (1.5), value: visible)
                    .padding (.bottom, 60)
            }
        }
        .contentShape (Rectangle ())
        .onTapGesture {
            guard visible else { return }
            withAnimation (.easeOut (duration: 0.6)) {
                visible = false
            }
            DispatchQueue.main.asyncAfter (deadline: .now () + 0.65) {
                onDismiss ()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter (deadline: .now () + 0.3) {
                visible = true
            }
        }
    }

    private func romanNumeral (for n: Int) -> String {
        switch n {
        case 1: return "I"
        case 2: return "II"
        case 3: return "III"
        case 4: return "IV"
        default: return "\(n)"
        }
    }
}

// MARK: - EndGameView

/// Full-screen ending screen shown after the credits beat.
/// Displays the ending title, flame description, and a Play Again option.
struct EndGameView: View {
    let ending: Ending
    let onPlayAgain: () -> Void

    @State private var visible: Bool = false
    @State private var detailVisible: Bool = false

    private let parchment  = Color (red: 0.96, green: 0.91, blue: 0.82)
    private let ochre      = Color (red: 0.72, green: 0.52, blue: 0.28)
    private let dimParch   = Color (red: 0.65, green: 0.58, blue: 0.46)
    private let bgColor    = Color (red: 0.06, green: 0.05, blue: 0.04)

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea ()

            // Subtle flame glow
            RadialGradient (
                colors: [
                    ochre.opacity (0.08),
                    Color.clear
                ],
                center: UnitPoint (x: 0.5, y: 0.45),
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea ()

            VStack (spacing: 0) {
                Spacer ()

                // Flame icon
                Image (systemName: "flame")
                    .font (.system (size: 32, weight: .ultraLight))
                    .foregroundColor (ochre.opacity (0.6))
                    .padding (.bottom, 36)
                    .opacity (visible ? 1 : 0)

                // Ending title
                Text (ending.title.uppercased ())
                    .font (.system (size: 28, weight: .ultraLight, design: .serif))
                    .tracking (10)
                    .foregroundColor (parchment.opacity (0.88))
                    .opacity (visible ? 1 : 0)

                // Divider
                Rectangle ()
                    .fill (ochre.opacity (0.3))
                    .frame (width: 48, height: 0.5)
                    .padding (.top, 24)
                    .padding (.bottom, 24)
                    .opacity (visible ? 1 : 0)

                // Flame description
                Text (ending.flameDescription)
                    .font (.system (size: 14, weight: .ultraLight, design: .serif))
                    .foregroundColor (dimParch.opacity (0.7))
                    .tracking (2)
                    .opacity (detailVisible ? 1 : 0)

                // Ending subtitle
                Text (endingSubtitle)
                    .font (.system (size: 12, weight: .ultraLight, design: .serif))
                    .foregroundColor (dimParch.opacity (0.45))
                    .multilineTextAlignment (.center)
                    .lineSpacing (6)
                    .padding (.horizontal, 56)
                    .padding (.top, 20)
                    .opacity (detailVisible ? 1 : 0)

                Spacer ()
                Spacer ()

                // Play Again
                Button {
                    onPlayAgain ()
                } label: {
                    VStack (spacing: 8) {
                        Text ("PLAY AGAIN")
                            .font (.system (size: 11, weight: .light, design: .serif))
                            .foregroundColor (parchment.opacity (0.6))
                            .tracking (8)

                        Rectangle ()
                            .fill (ochre.opacity (0.35))
                            .frame (width: 32, height: 0.5)
                    }
                }
                .opacity (detailVisible ? 1 : 0)
                .padding (.bottom, 72)
            }
            .animation (.easeIn (duration: 1.4), value: visible)
            .animation (.easeIn (duration: 1.4).delay (1.8), value: detailVisible)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter (deadline: .now () + 0.5) {
                visible = true
            }
            DispatchQueue.main.asyncAfter (deadline: .now () + 2.2) {
                detailVisible = true
            }
        }
    }

    private var endingSubtitle: String {
        switch ending {
        case .theProphet:
            return "She spoke truth.\nShe paid for it.\nShe is at peace."
        case .theMartyr:
            return "She believed.\nShe compromised.\nShe lives with both."
        case .thePhilosopher:
            return "She no longer believes.\nShe told the truth anyway.\nThat is its own kind of faith."
        case .theHollow:
            return "She says the words.\nShe finds them.\nShe always does."
        }
    }
}

// MARK: - Preview

#Preview {
    let knowledge = KnowledgeState ()
    let engine = NarrativeEngine (nodes: ActI.nodes + ActII.nodes + ActIII.nodes + ActIV.nodes + Epilogue.nodes, knowledge: knowledge)
    return SceneView (engine: engine)
}
