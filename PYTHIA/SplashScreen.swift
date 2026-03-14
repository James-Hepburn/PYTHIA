// SplashScreen.swift
// PYTHIA
//
// The title screen. First thing the player sees.
// Shows New Game / Continue based on whether a save exists.

import SwiftUI

struct SplashScreen: View {
    var hasSave: Bool
    var onNewGame: () -> Void
    var onContinue: () -> Void

    @EnvironmentObject private var audio: AudioManager

    // MARK: - Animation state

    @State private var flameVisible:     Bool = false
    @State private var ornamentVisible:  Bool = false
    @State private var titleVisible:     Bool = false
    @State private var taglineVisible:   Bool = false
    @State private var beginVisible:     Bool = false
    @State private var flamePulse:       Bool = false
    @State private var beginPulse:       Double = 1.0
    @State private var transitioning:    Bool = false

    // MARK: - Palette

    private let void         = Color (red: 0.06, green: 0.05, blue: 0.04)
    private let parchment    = Color (red: 0.94, green: 0.88, blue: 0.76)
    private let dimParchment = Color (red: 0.65, green: 0.58, blue: 0.46)
    private let flameOrange  = Color (red: 0.95, green: 0.55, blue: 0.18)
    private let flameGold    = Color (red: 0.98, green: 0.78, blue: 0.30)
    private let flameCore    = Color (red: 1.00, green: 0.95, blue: 0.80)
    private let ochre        = Color (red: 0.72, green: 0.50, blue: 0.22)

    // MARK: - Body

    var body: some View {
        ZStack {
            void.ignoresSafeArea ()

            RadialGradient (
                colors: [
                    flameOrange.opacity (flamePulse ? 0.13 : 0.08),
                    flameGold.opacity (flamePulse ? 0.06 : 0.03),
                    Color.clear
                ],
                center: UnitPoint (x: 0.5, y: 0.34),
                startRadius: 0,
                endRadius: 260
            )
            .ignoresSafeArea ()
            .opacity (flameVisible ? 1 : 0)
            .animation (.easeInOut (duration: 2.8).repeatForever (autoreverses: true), value: flamePulse)

            VStack (spacing: 0) {
                Spacer ()

                flameView
                    .padding (.bottom, 36)

                ornamentLine
                    .padding (.bottom, 28)
                    .opacity (ornamentVisible ? 1 : 0)
                    .offset (y: ornamentVisible ? 0 : 6)
                    .animation (.easeOut (duration: 1.0).delay (1.6), value: ornamentVisible)

                Text ("PYTHIA")
                    .font (.system (size: 52, weight: .ultraLight, design: .serif))
                    .foregroundColor (parchment)
                    .tracking (18)
                    .opacity (titleVisible ? 1 : 0)
                    .offset (y: titleVisible ? 0 : 12)
                    .animation (.easeOut (duration: 1.2).delay (2.2), value: titleVisible)

                VStack (spacing: 6) {
                    Text ("She who knows.")
                        .font (.system (size: 13, weight: .ultraLight, design: .serif))
                        .foregroundColor (dimParchment)
                        .tracking (3)

                    Text ("She who cannot speak.")
                        .font (.system (size: 13, weight: .ultraLight, design: .serif))
                        .foregroundColor (dimParchment.opacity (0.7))
                        .tracking (3)
                }
                .padding (.top, 16)
                .opacity (taglineVisible ? 1 : 0)
                .animation (.easeIn (duration: 1.4).delay (3.2), value: taglineVisible)

                Spacer ()
                Spacer ()

                Text ("DELPHI  ·  480 BC")
                    .font (.system (size: 9, weight: .ultraLight, design: .serif))
                    .foregroundColor (dimParchment.opacity (0.35))
                    .tracking (5)
                    .opacity (taglineVisible ? 1 : 0)
                    .animation (.easeIn (duration: 1.0).delay (3.8), value: taglineVisible)
                    .padding (.bottom, 32)

                // --- Begin buttons ---
                beginButtons
                    .padding (.bottom, 64)
            }
        }
        .onAppear {
            runSequence ()
        }
    }

    // MARK: - Begin Buttons

    /// Shows Continue + New Game if a save exists, otherwise just Begin.
    private var beginButtons: some View {
        VStack (spacing: 28) {
            if hasSave {
                // Continue — primary action
                splashButton (label: "CONTINUE") {
                    guard !transitioning else { return }
                    transitioning = true
                    fadeOut { onContinue () }
                }

                // New Game — secondary, dimmer
                Button {
                    guard !transitioning else { return }
                    transitioning = true
                    fadeOut { onNewGame () }
                } label: {
                    Text ("NEW GAME")
                        .font (.system (size: 10, weight: .ultraLight, design: .serif))
                        .foregroundColor (dimParchment.opacity (beginPulse * 0.45))
                        .tracking (6)
                }
            } else {
                // No save — single Begin button
                splashButton (label: "BEGIN") {
                    guard !transitioning else { return }
                    transitioning = true
                    fadeOut { onNewGame () }
                }
            }
        }
        .opacity (beginVisible ? 1 : 0)
        .onAppear {
            withAnimation (.easeInOut (duration: 2.0).repeatForever (autoreverses: true).delay (5.0)) {
                beginPulse = 0.6
            }
        }
    }

    private func splashButton (label: String, action: @escaping () -> Void) -> some View {
        Button {
            action ()
        } label: {
            VStack (spacing: 8) {
                Text (label)
                    .font (.system (size: 11, weight: .light, design: .serif))
                    .foregroundColor (parchment.opacity (beginPulse * 0.75))
                    .tracking (8)

                Rectangle ()
                    .fill (ochre.opacity (beginPulse * 0.4))
                    .frame (width: 32, height: 0.5)
            }
        }
    }

    private func fadeOut (completion: @escaping () -> Void) {
        audio.stopSplashMusic (fadeDuration: 0.8)
        withAnimation (.easeIn (duration: 0.8)) {
            beginPulse = 0
        }
        DispatchQueue.main.asyncAfter (deadline: .now () + 0.7) {
            completion ()
        }
    }

    // MARK: - Flame

    private var flameView: some View {
        ZStack {
            ForEach ([0, 1, 2], id: \.self) { i in
                Circle ()
                    .fill (
                        RadialGradient (
                            colors: [
                                flameOrange.opacity (0.12 - Double (i) * 0.035),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 28 + Double (i) * 14
                        )
                    )
                    .frame (width: CGFloat (56 + i * 28), height: CGFloat (56 + i * 28))
                    .scaleEffect (flamePulse ? 1.08 : 0.96)
                    .animation (
                        .easeInOut (duration: 2.2 + Double (i) * 0.3)
                        .repeatForever (autoreverses: true)
                        .delay (Double (i) * 0.15),
                        value: flamePulse
                    )
            }

            ZStack {
                Image (systemName: "flame.fill")
                    .font (.system (size: 44, weight: .ultraLight))
                    .foregroundColor (flameOrange.opacity (0.4))
                    .blur (radius: 6)
                    .offset (y: 2)

                Image (systemName: "flame.fill")
                    .font (.system (size: 44, weight: .ultraLight))
                    .foregroundColor (flameOrange)

                Image (systemName: "flame.fill")
                    .font (.system (size: 28, weight: .ultraLight))
                    .foregroundColor (flameCore.opacity (0.9))
                    .offset (y: 4)
            }
            .scaleEffect (flamePulse ? 1.04 : 0.97)
            .animation (
                .easeInOut (duration: 1.8).repeatForever (autoreverses: true),
                value: flamePulse
            )
        }
        .opacity (flameVisible ? 1 : 0)
        .animation (.easeIn (duration: 2.0), value: flameVisible)
    }

    // MARK: - Ornament

    private var ornamentLine: some View {
        HStack (spacing: 10) {
            line
            diamond
            Text ("·")
                .font (.system (size: 8))
                .foregroundColor (ochre.opacity (0.5))
            diamond
            line
        }
    }

    private var line: some View {
        Rectangle ()
            .fill (ochre.opacity (0.35))
            .frame (width: 48, height: 0.5)
    }

    private var diamond: some View {
        Rectangle ()
            .fill (ochre.opacity (0.55))
            .frame (width: 4, height: 4)
            .rotationEffect (.degrees (45))
    }

    // MARK: - Sequence

    private func runSequence () {
        audio.playSplashMusic ()
        DispatchQueue.main.asyncAfter (deadline: .now () + 0.4) {
            flameVisible = true
            flamePulse = true
        }
        DispatchQueue.main.asyncAfter (deadline: .now () + 1.4) {
            ornamentVisible = true
        }
        DispatchQueue.main.asyncAfter (deadline: .now () + 2.0) {
            titleVisible = true
        }
        DispatchQueue.main.asyncAfter (deadline: .now () + 3.0) {
            taglineVisible = true
        }
        DispatchQueue.main.asyncAfter (deadline: .now () + 4.6) {
            beginVisible = true
        }
    }
}

#Preview {
    SplashScreen (hasSave: false, onNewGame: {}, onContinue: {})
}
