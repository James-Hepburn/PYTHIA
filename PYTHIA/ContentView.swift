// ContentView.swift
// PYTHIA
//
// Root view. Shows SplashScreen until the player taps Begin,
// then transitions into the game with a slow fade.

import SwiftUI

struct ContentView: View {
    @StateObject private var knowledge = KnowledgeState ()
    @State private var gameStarted: Bool = false
    @State private var splashOpacity: Double = 1.0

    var body: some View {
        ZStack {
            // --- Game (underneath, ready before transition) ---
            if gameStarted {
                SceneView (
                    engine: NarrativeEngine (
                        nodes: ActI.nodes,
                        knowledge: knowledge
                    )
                )
                .transition (.opacity)
            }

            // --- Splash (on top until dismissed) ---
            if !gameStarted {
                SplashScreen {
                    // Fade out splash, reveal game
                    withAnimation (.easeInOut (duration: 1.0)) {
                        gameStarted = true
                    }
                }
                .transition (.opacity)
            }
        }
        .ignoresSafeArea ()
        .preferredColorScheme (.dark)
    }
}

#Preview {
    ContentView ()
}
