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

    enum Phase { case splash, actCard, continueCard, game }
    @State private var phase: Phase = .splash

    /// The act number to show on the continue title card.
    /// Read from KnowledgeState before loadSave() advances the engine.
    @State private var savedActNumber: Int = 1

    @StateObject private var engine: NarrativeEngine = {
        let k = KnowledgeState ()
        return NarrativeEngine (
            nodes: ActI.nodes + ActII.nodes + ActIII.nodes + ActIV.nodes + Epilogue.nodes,
            knowledge: k,
            startNodeID: nil
        )
    } ()

    /// Audio system — owned here so it lives for the full app lifetime.
    @StateObject private var audio = AudioManager ()

    // MARK: Body

    var body: some View {
        ZStack {

            // --- Game — always in hierarchy so engine stays alive ---
            SceneView (engine: engine, onNewGame: handleNewGame)
                .opacity (phase == .game ? 1 : 0)
                .allowsHitTesting (phase == .game)

            // --- Act I title card (new game) ---
            if phase == .actCard {
                ActTitleCard (actNumber: 1) {
                    withAnimation (.easeInOut (duration: 0.8)) {
                        phase = .game
                    }
                    audio.startGameAudio ()
                }
                .transition (.opacity)
                .zIndex (1)
            }

            // --- Act title card (continue) ---
            if phase == .continueCard {
                ActTitleCard (actNumber: savedActNumber) {
                    engine.loadSave ()
                    withAnimation (.easeInOut (duration: 0.8)) {
                        phase = .game
                    }
                    audio.startGameAudio ()
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
        .environmentObject (audio)
    }

    // MARK: - Actions

    /// Start a fresh playthrough — delete any existing save, reset engine and audio.
    private func handleNewGame () {
        KnowledgeState.deleteSave ()
        engine.resetToStart ()
        audio.resetAudio ()
        withAnimation (.easeInOut (duration: 0.6)) {
            phase = .actCard
        }
    }

    /// Resume from the last saved node — show the act card first, then load.
    private func handleContinue () {
        savedActNumber = KnowledgeState.savedActNumber ()
        withAnimation (.easeInOut (duration: 0.6)) {
            phase = .continueCard
        }
    }
}

#Preview {
    ContentView ()
}
