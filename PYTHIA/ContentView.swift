// ContentView.swift
// PYTHIA
//
// Root view. Manages the top-level game phases:
//   splash      — SplashScreen with New Game / Continue choice
//   actCard     — Act I title card (first run only)
//   game        — SceneView, the main game loop
//
// Persistence:
//   KnowledgeState.hasSave     — true if a save file exists on disk
//   KnowledgeState.load ()     — loads saved state into the knowledge instance
//   KnowledgeState.deleteSave () — erases save on New Game
//
// The NarrativeEngine is hoisted to @StateObject so it is created once
// and never reconstructed during phase transitions.

import SwiftUI

struct ContentView: View {

    // MARK: State

    enum Phase { case splash, actCard, game }
    @State private var phase: Phase = .splash

    @StateObject private var engine: NarrativeEngine = {
        let k = KnowledgeState ()
        return NarrativeEngine (
            nodes: ActI.nodes + ActII.nodes + ActIII.nodes + ActIV.nodes + Epilogue.nodes,
            knowledge: k,
            startNodeID: nil
        )
    } ()

    // MARK: Body

    var body: some View {
        ZStack {

            // --- Game — always in hierarchy so engine stays alive ---
            SceneView (engine: engine, onNewGame: handleNewGame)
                .opacity (phase == .game ? 1 : 0)
                .allowsHitTesting (phase == .game)

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
                SplashScreen (
                    hasSave: KnowledgeState.hasSave,
                    onNewGame: handleNewGame,
                    onContinue: handleContinue
                )
                .transition (.opacity)
                .zIndex (2)
            }
        }
        .ignoresSafeArea ()
        .preferredColorScheme (.dark)
    }

    // MARK: - Actions

    /// Start a fresh playthrough — delete any existing save, reset engine.
    private func handleNewGame () {
        KnowledgeState.deleteSave ()
        engine.resetToStart ()
        withAnimation (.easeInOut (duration: 0.6)) {
            phase = .actCard
        }
    }

    /// Resume from the last saved node.
    private func handleContinue () {
        engine.loadSave ()
        withAnimation (.easeInOut (duration: 0.6)) {
            phase = .game
        }
    }
}

#Preview {
    ContentView ()
}
