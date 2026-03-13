// VisionView.swift
// PYTHIA
//
// The vision mechanic — the defining feature of the game.
// When Mara enters the adyton, the world desaturates and fragments of
// the future appear. The player taps to examine, then selects 2–3
// fragments they feel are most significant. Their interpretation
// shapes which prophecy wordings are available in the dialogue phase.
//
// Usage:
//   VisionView (fragments: myFragments) { interpretation in
//       // interpretation is an array of selected Fragment IDs
//       // pass these back to your narrative engine / KnowledgeState
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
/// Fragments are defined in your narrative data layer and passed into VisionView.
struct Fragment: Identifiable {
    let id: String                    // Unique ID, e.g. "thermopylae_pass"
    let type: FragmentType
    let significance: String          // Written to KnowledgeState journal on selection
}

// MARK: - VisionView

struct VisionView: View {

    // The fragments to display — provided by the narrative engine
    let fragments: [Fragment]

    // Called when the player finalises their interpretation.
    // Returns the IDs of the 2–3 selected fragments.
    var onInterpretationComplete: ([String]) -> Void

    // MARK: State

    @State private var selectedIDs: Set<String> = []
    @State private var examinedID: String? = nil         // Currently examined fragment
    @State private var isVisible: Bool = false           // Controls entrance animation
    @State private var readyToConfirm: Bool = false      // True when 2–3 selected

    // Maximum fragments the player may select before confirming
    private let maxSelection = 3
    private let minSelection = 2

    // MARK: Colours — cold vision palette (contrasts with the warm game world)

    private let visionBackground = Color (red: 0.04, green: 0.04, blue: 0.10)
    private let fragmentBorder    = Color (red: 0.50, green: 0.60, blue: 0.80)
    private let selectedGlow      = Color (red: 0.70, green: 0.80, blue: 1.00)
    private let dimText           = Color (red: 0.55, green: 0.60, blue: 0.70)
    private let brightText        = Color (red: 0.90, green: 0.92, blue: 0.98)

    // MARK: Body

    var body: some View {
        ZStack {

            // --- Background: pure darkness ---
            visionBackground
                .ignoresSafeArea ()

            // --- Subtle noise grain overlay for atmosphere ---
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

                // --- Confirm button — appears once min selection reached ---
                if readyToConfirm {
                    confirmButton
                        .transition (.opacity.combined (with: .move (edge: .bottom)))
                }

                // --- Selection counter ---
                selectionCounter
                    .padding (.bottom, 32)
            }
            .padding (.horizontal, 24)

            // --- Fragment detail overlay ---
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
                FragmentCell (
                    fragment: fragment,
                    isSelected: selectedIDs.contains (fragment.id),
                    isExamined: examinedID == fragment.id,
                    fragmentBorder: fragmentBorder,
                    selectedGlow: selectedGlow,
                    dimText: dimText,
                    brightText: brightText
                )
                .opacity (isVisible ? 1 : 0)
                // Staggered entrance — fragments drift in one by one
                .animation (
                    .easeOut (duration: 0.8).delay (Double (index) * 0.15 + 0.6),
                    value: isVisible
                )
                .onTapGesture {
                    handleFragmentTap (fragment.id)
                }
                .onLongPressGesture {
                    handleFragmentExamine (fragment.id)
                }
            }
        }
    }

    /// Bottom confirm button — styled as carved stone inscription
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
                        .fill (selectedGlow.opacity (0.85))
                )
        }
        .padding (.bottom, 16)
    }

    /// Selection counter — shows how many fragments are selected
    private var selectionCounter: some View {
        HStack (spacing: 6) {
            ForEach (0..<maxSelection, id: \.self) { i in
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
            Color.black.opacity (0.85)
                .ignoresSafeArea ()
                .onTapGesture {
                    withAnimation (.easeOut (duration: 0.3)) {
                        examinedID = nil
                    }
                }

            VStack (spacing: 24) {
                // Large fragment display
                fragmentLargeDisplay (fragment: fragment)

                // Significance text — poetic, not explanatory
                Text (fragment.significance)
                    .font (.system (size: 15, weight: .light, design: .serif))
                    .foregroundColor (dimText)
                    .multilineTextAlignment (.center)
                    .lineSpacing (6)
                    .padding (.horizontal, 48)

                Text ("tap to return")
                    .font (.system (size: 10, weight: .ultraLight, design: .serif))
                    .foregroundColor (dimText.opacity (0.5))
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

    /// Tap: toggle fragment selection (max 3)
    private func handleFragmentTap (_ id: String) {
        withAnimation (.easeInOut (duration: 0.2)) {
            if selectedIDs.contains (id) {
                selectedIDs.remove (id)
            } else if selectedIDs.count < maxSelection {
                selectedIDs.insert (id)
            }
            readyToConfirm = selectedIDs.count >= minSelection
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
/// Extracted to keep VisionView body readable.
struct FragmentCell: View {

    let fragment: Fragment
    let isSelected: Bool
    let isExamined: Bool
    let fragmentBorder: Color
    let selectedGlow: Color
    let dimText: Color
    let brightText: Color

    var body: some View {
        ZStack {
            // Background — subtle glow when selected
            RoundedRectangle (cornerRadius: 4)
                .fill (isSelected
                    ? selectedGlow.opacity (0.12)
                    : Color.white.opacity (0.03))
                .overlay (
                    RoundedRectangle (cornerRadius: 4)
                        .stroke (
                            isSelected ? selectedGlow.opacity (0.7) : fragmentBorder.opacity (0.25),
                            lineWidth: isSelected ? 1.2 : 0.6
                        )
                )
                // Pulse animation on selected fragments
                .shadow (color: isSelected ? selectedGlow.opacity (0.3) : .clear, radius: 8)

            // Fragment content
            fragmentContent
                .padding (16)
        }
        .aspectRatio (1, contentMode: .fit)
        .scaleEffect (isSelected ? 1.04 : 1.0)
        .animation (.spring (response: 0.3, dampingFraction: 0.7), value: isSelected)
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
                significance: "golden and heavy — the weight of abundance"
            ),
            Fragment (
                id: "harvest_rain",
                type: .sensation (text: "cold water on dry stone"),
                significance: "relief arriving too late, or just in time"
            ),
            Fragment (
                id: "harvest_word",
                type: .word (text: "WAIT"),
                significance: "patience, or warning — it is not yet clear"
            ),
            Fragment (
                id: "harvest_sun",
                type: .colour (hue: .orange),
                significance: "the colour of a season turning"
            ),
            Fragment (
                id: "harvest_fire",
                type: .image (symbolName: "flame"),
                significance: "destruction, or warmth — the same light, different hands"
            ),
            Fragment (
                id: "harvest_silence",
                type: .sensation (text: "the absence of sound\nafter a crowd departs"),
                significance: "something has already been decided"
            )
        ]
    ) { selectedIDs in
    }
}
