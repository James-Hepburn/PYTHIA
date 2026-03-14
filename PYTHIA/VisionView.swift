// VisionView.swift
// PYTHIA
//
// The vision mechanic — the defining feature of the game.
// When Mara enters the adyton, the world desaturates and fragments of
// the future appear. The player taps to examine each one, then selects
// exactly 3 fragments. Those 3 fragments become the only dialogue choices
// available in the prophecy conversation that follows — no safety net,
// no baseline options. You speak with what you saw.
//
// Each Fragment carries a dialogueOption string — the oracle-voiced line
// that appears as a dialogue button in the scene after the vision ends.
// The significance string is shown in the examine overlay and logged to
// the journal. The player sees significance when they look closely;
// they speak dialogueOption when they face the supplicant.
//
// Usage:
//   VisionView (fragments: myFragments) { selectedIDs in
//       // Exactly 3 IDs — pass to engine.visionSessionCompleted()
//   }

import SwiftUI

// MARK: - Data Models

/// The type of a vision fragment — each type has its own
/// visual and (eventually) audio treatment.
enum FragmentType {
    case image (symbolName: String)   // SF Symbol representing a visual impression
    case word (text: String)          // A word in English (or later Greek)
    case sensation (text: String)     // A brief poetic description of a physical feeling
    case colour (hue: Color)          // A pure colour field — no label
}

/// A single fragment of prophetic vision.
/// Fragments are defined in the narrative data layer and passed into VisionView.
struct Fragment: Identifiable {
    let id: String                    // Unique ID, e.g. "thermopylae_pass"
    let type: FragmentType
    let significance: String          // Poetic meaning — shown in examine overlay, logged to journal
    let dialogueOption: String        // The oracle-voiced line this fragment unlocks as a dialogue choice
}

// MARK: - VisionView

struct VisionView: View {

    // The fragments to display — provided by the narrative engine.
    // Author 6–9 fragments per session; the player chooses exactly 3.
    let fragments: [Fragment]

    // Called when the player confirms their selection.
    // Always returns exactly 3 IDs.
    var onInterpretationComplete: ([String]) -> Void

    // MARK: State

    @State private var selectedIDs: Set<String> = []
    @State private var examinedID: String? = nil         // Currently examined fragment
    @State private var isVisible: Bool = false           // Controls entrance animation
    @State private var confirmPulse: Bool = false        // Pulses confirm button when ready

    // Selection is locked to exactly 3
    private let requiredSelection = 3

    // MARK: Colours — cold vision palette (contrasts with the warm game world)

    private let visionBackground = Color (red: 0.04, green: 0.04, blue: 0.10)
    private let fragmentBorder    = Color (red: 0.50, green: 0.60, blue: 0.80)
    private let selectedGlow      = Color (red: 0.70, green: 0.80, blue: 1.00)
    private let dimText           = Color (red: 0.55, green: 0.60, blue: 0.70)
    private let brightText        = Color (red: 0.90, green: 0.92, blue: 0.98)
    private let lockedBorder      = Color (red: 0.30, green: 0.33, blue: 0.42)

    // MARK: Computed

    private var readyToConfirm: Bool { selectedIDs.count == requiredSelection }

    // MARK: Body

    var body: some View {
        ZStack {

            // --- Background: pure darkness ---
            visionBackground
                .ignoresSafeArea ()

            // --- Subtle grain overlay for atmosphere ---
            Rectangle ()
                .fill (
                    LinearGradient (
                        colors: [
                            Color.white.opacity (0.02),
                            Color.clear,
                            Color.white.opacity (0.01)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea ()

            VStack (spacing: 0) {

                // --- Header ---
                visionHeader

                Spacer ()

                // --- Fragment grid ---
                fragmentGrid

                Spacer ()

                // --- Confirm button — appears once exactly 3 are selected ---
                if readyToConfirm {
                    confirmButton
                        .transition (.opacity.combined (with: .move (edge: .bottom)))
                }

                // --- Selection counter: 3 dots, fills as player selects ---
                selectionCounter
                    .padding (.bottom, 32)
            }
            .padding (.horizontal, 24)

            // --- Fragment detail overlay (long press) ---
            if let id = examinedID,
               let fragment = fragments.first (where: { $0.id == id }) {
                fragmentDetailOverlay (fragment: fragment)
            }
        }
        .onAppear {
            withAnimation (.easeIn (duration: 1.2)) {
                isVisible = true
            }
        }
        .onChange (of: readyToConfirm) {
            if readyToConfirm {
                withAnimation (.easeInOut (duration: 1.6).repeatForever (autoreverses: true)) {
                    confirmPulse = true
                }
            }
        }
    }

    // MARK: - Subviews

    /// Top header — sparse, atmospheric
    private var visionHeader: some View {
        VStack (spacing: 8) {
            Text ("· · ·")
                .font (.system (size: 14, weight: .ultraLight, design: .serif))
                .foregroundColor (dimText)
                .tracking (8)

            Text ("SHE SEES")
                .font (.system (size: 11, weight: .light, design: .serif))
                .foregroundColor (dimText)
                .tracking (6)
        }
        .padding (.top, 56)
        .opacity (isVisible ? 1 : 0)
        .animation (.easeIn (duration: 1.6).delay (0.4), value: isVisible)
    }

    /// The grid of vision fragments
    private var fragmentGrid: some View {
        let columns = [
            GridItem (.flexible (), spacing: 16),
            GridItem (.flexible (), spacing: 16),
            GridItem (.flexible (), spacing: 16)
        ]

        return LazyVGrid (columns: columns, spacing: 20) {
            ForEach (Array (fragments.enumerated ()), id: \.element.id) { index, fragment in
                let isSelected = selectedIDs.contains (fragment.id)
                // A fragment is locked (untappable) if 3 are already chosen and this isn't one of them
                let isLocked = selectedIDs.count == requiredSelection && !isSelected

                FragmentCell (
                    fragment: fragment,
                    isSelected: isSelected,
                    isExamined: examinedID == fragment.id,
                    isLocked: isLocked,
                    fragmentBorder: fragmentBorder,
                    selectedGlow: selectedGlow,
                    lockedBorder: lockedBorder,
                    dimText: dimText,
                    brightText: brightText
                )
                .opacity (isVisible ? 1 : 0)
                // Staggered entrance
                .animation (
                    .easeOut (duration: 0.8).delay (Double (index) * 0.15 + 0.6),
                    value: isVisible
                )
                .onTapGesture {
                    if !isLocked { handleFragmentTap (fragment.id) }
                }
                .onLongPressGesture {
                    handleFragmentExamine (fragment.id)
                }
            }
        }
    }

    /// Confirm button — only appears when exactly 3 are selected
    private var confirmButton: some View {
        Button {
            onInterpretationComplete (Array (selectedIDs))
        } label: {
            Text ("SPEAK THE PROPHECY")
                .font (.system (size: 12, weight: .light, design: .serif))
                .tracking (4)
                .foregroundColor (visionBackground)
                .padding (.horizontal, 32)
                .padding (.vertical, 14)
                .background (
                    RoundedRectangle (cornerRadius: 2)
                        .fill (selectedGlow.opacity (confirmPulse ? 0.95 : 0.85))
                )
        }
        .padding (.bottom, 16)
    }

    /// Three dots — fills as fragments are selected, locked at 3
    private var selectionCounter: some View {
        HStack (spacing: 6) {
            ForEach (0..<requiredSelection, id: \.self) { i in
                Circle ()
                    .fill (i < selectedIDs.count ? selectedGlow : fragmentBorder.opacity (0.3))
                    .frame (width: 5, height: 5)
                    .animation (.easeInOut (duration: 0.2), value: selectedIDs.count)
            }
        }
        .padding (.bottom, 8)
    }

    /// Full-screen overlay when a fragment is examined (long press)
    private func fragmentDetailOverlay (fragment: Fragment) -> some View {
        ZStack {
            Color.black.opacity (0.88)
                .ignoresSafeArea ()
                .onTapGesture {
                    withAnimation (.easeOut (duration: 0.3)) {
                        examinedID = nil
                    }
                }

            VStack (spacing: 24) {
                // Large fragment display
                fragmentLargeDisplay (fragment: fragment)

                // Significance — poetic, not explanatory
                Text (fragment.significance)
                    .font (.system (size: 15, weight: .light, design: .serif))
                    .foregroundColor (dimText)
                    .multilineTextAlignment (.center)
                    .lineSpacing (6)
                    .padding (.horizontal, 48)

                // Divider
                Rectangle ()
                    .fill (fragmentBorder.opacity (0.2))
                    .frame (width: 32, height: 0.5)

                // Dialogue option preview — what selecting this fragment will say
                Text ("\"\(fragment.dialogueOption)\"")
                    .font (.system (size: 13, weight: .ultraLight, design: .serif))
                    .foregroundColor (selectedGlow.opacity (0.55))
                    .multilineTextAlignment (.center)
                    .lineSpacing (5)
                    .italic ()
                    .padding (.horizontal, 40)

                Text ("tap to return")
                    .font (.system (size: 10, weight: .ultraLight, design: .serif))
                    .foregroundColor (dimText.opacity (0.4))
                    .tracking (3)
            }
        }
        .transition (.opacity)
    }

    /// Large version of a fragment for the examine overlay
    private func fragmentLargeDisplay (fragment: Fragment) -> some View {
        Group {
            switch fragment.type {
            case .image (let symbol):
                Image (systemName: symbol)
                    .font (.system (size: 64, weight: .ultraLight))
                    .foregroundColor (selectedGlow)

            case .word (let text):
                Text (text)
                    .font (.system (size: 48, weight: .ultraLight, design: .serif))
                    .foregroundColor (brightText)
                    .tracking (8)

            case .sensation (let text):
                Text (text)
                    .font (.system (size: 18, weight: .ultraLight, design: .serif))
                    .foregroundColor (dimText)
                    .multilineTextAlignment (.center)
                    .lineSpacing (8)
                    .padding (.horizontal, 40)

            case .colour (let hue):
                RoundedRectangle (cornerRadius: 4)
                    .fill (hue.opacity (0.6))
                    .frame (width: 80, height: 80)
            }
        }
    }

    // MARK: - Interaction Logic

    /// Tap: toggle selection. Hard cap at exactly 3.
    private func handleFragmentTap (_ id: String) {
        withAnimation (.easeInOut (duration: 0.2)) {
            if selectedIDs.contains (id) {
                selectedIDs.remove (id)
            } else if selectedIDs.count < requiredSelection {
                selectedIDs.insert (id)
            }
            // No action if count is already 3 and this fragment isn't selected —
            // the isLocked flag on the cell handles the visual, the tap guard above handles logic
        }
    }

    /// Long press: examine a fragment in detail
    private func handleFragmentExamine (_ id: String) {
        withAnimation (.easeInOut (duration: 0.3)) {
            examinedID = (examinedID == id) ? nil : id
        }
    }
}

// MARK: - FragmentCell

/// A single fragment tile in the vision grid.
struct FragmentCell: View {

    let fragment: Fragment
    let isSelected: Bool
    let isExamined: Bool
    let isLocked: Bool          // True when 3 are chosen and this isn't one of them
    let fragmentBorder: Color
    let selectedGlow: Color
    let lockedBorder: Color
    let dimText: Color
    let brightText: Color

    private var borderColor: Color {
        if isSelected { return selectedGlow.opacity (0.7) }
        if isLocked   { return lockedBorder.opacity (0.15) }
        return fragmentBorder.opacity (0.25)
    }

    private var fillColor: Color {
        if isSelected { return selectedGlow.opacity (0.12) }
        if isLocked   { return Color.white.opacity (0.01) }
        return Color.white.opacity (0.03)
    }

    var body: some View {
        ZStack {
            RoundedRectangle (cornerRadius: 4)
                .fill (fillColor)
                .overlay (
                    RoundedRectangle (cornerRadius: 4)
                        .stroke (borderColor, lineWidth: isSelected ? 1.2 : 0.6)
                )
                .shadow (color: isSelected ? selectedGlow.opacity (0.3) : .clear, radius: 8)

            fragmentContent
                .padding (16)
        }
        .aspectRatio (1, contentMode: .fit)
        .scaleEffect (isSelected ? 1.04 : 1.0)
        .opacity (isLocked ? 0.35 : 1.0)
        .animation (.spring (response: 0.3, dampingFraction: 0.7), value: isSelected)
        .animation (.easeInOut (duration: 0.3), value: isLocked)
    }

    @ViewBuilder
    private var fragmentContent: some View {
        switch fragment.type {

        case .image (let symbol):
            Image (systemName: symbol)
                .font (.system (size: 28, weight: .ultraLight))
                .foregroundColor (isSelected ? selectedGlow : fragmentBorder.opacity (0.7))

        case .word (let text):
            Text (text)
                .font (.system (size: 14, weight: .light, design: .serif))
                .foregroundColor (isSelected ? brightText : dimText)
                .tracking (2)
                .multilineTextAlignment (.center)

        case .sensation (let text):
            Text (text)
                .font (.system (size: 10, weight: .ultraLight, design: .serif))
                .foregroundColor (isSelected ? dimText : dimText.opacity (0.6))
                .multilineTextAlignment (.center)
                .lineSpacing (3)

        case .colour (let hue):
            RoundedRectangle (cornerRadius: 2)
                .fill (hue.opacity (isSelected ? 0.7 : 0.35))
                .padding (12)
        }
    }
}

// MARK: - Preview

#Preview {
    VisionView (
        fragments: [
            Fragment (
                id: "harvest_grain",
                type: .image (symbolName: "sparkle"),
                significance: "golden and heavy — the weight of abundance",
                dialogueOption: "I saw grain, full and heavy. The earth does not forget a patient hand."
            ),
            Fragment (
                id: "harvest_rain",
                type: .sensation (text: "cold water on dry stone"),
                significance: "relief arriving too late, or just in time",
                dialogueOption: "Wait for the third rain before you sow. The earth is not yet ready."
            ),
            Fragment (
                id: "harvest_word",
                type: .word (text: "WAIT"),
                significance: "patience, or warning — it is not yet clear",
                dialogueOption: "Apollo says: wait. I cannot tell you more than that. But wait."
            ),
            Fragment (
                id: "harvest_sun",
                type: .colour (hue: .orange),
                significance: "the colour of a season turning",
                dialogueOption: "The season turns in your favour. What the water withholds, patience returns."
            ),
            Fragment (
                id: "harvest_fire",
                type: .image (symbolName: "flame"),
                significance: "destruction, or warmth — the same light, different hands",
                dialogueOption: "I saw warmth where you expected ruin. Tend what you have with care."
            ),
            Fragment (
                id: "harvest_silence",
                type: .sensation (text: "the absence of sound\nafter a crowd departs"),
                significance: "something has already been decided",
                dialogueOption: "I believe it will hold — but not without care. The decision is already made in the earth."
            )
        ]
    ) { selectedIDs in
        print ("Selected: \(selectedIDs)")
    }
}
