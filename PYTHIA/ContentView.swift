// ContentView.swift
// PYTHIA
//
// Root view. Shows SplashScreen until the player taps Begin,
// then transitions into the game with a slow fade.

import SwiftUI

struct ContentView: View {
    @StateObject private var knowledge = KnowledgeState ()

    // NarrativeEngine hoisted to @StateObject so it is created once
    // and never reconstructed during phase transitions. Creating it
    // inline inside the ZStack body caused a new engine (and a new
    // advance() call) on every re-render, which swallowed the
    // ActTitleCard tap gesture.
    @StateObject private var engine: NarrativeEngine = {
        let k = KnowledgeState ()
        return NarrativeEngine (
            nodes: ActI.nodes + ActII.nodes + ActIII.nodes + ActIV.nodes,
            knowledge: k,
            startNodeID: nil        // always starts fresh for now
        )
    } ()

    enum Phase { case splash, actCard, game }
    @State private var phase: Phase = .splash

    var body: some View {
        ZStack {
            // --- Game — always in the hierarchy so the engine stays alive ---
            // Hidden behind the splash/act card until phase == .game.
            SceneView (engine: engine)
                .opacity (phase == .game ? 1 : 0)
                .allowsHitTesting (phase == .game)
                .transition (.opacity)

            // --- Act I title card ---
            if phase == .actCard {
                ActTitleCard (actNumber: 1) {
                    withAnimation (.easeInOut (duration: 0.8)) {
                        phase = .game
                    }
                }
                .transition (.opacity)
                .zIndex (1)
            }

            // --- Splash ---
            if phase == .splash {
                SplashScreen {
                    withAnimation (.easeInOut (duration: 0.6)) {
                        phase = .actCard
                    }
                }
                .transition (.opacity)
                .zIndex (2)
            }
        }
        .ignoresSafeArea ()
        .preferredColorScheme (.dark)
    }
}

#Preview {
    ContentView ()
}
