// AudioManager.swift
// PYTHIA
//
// The audio system. Manages all ambient sound and music across the game.
//
// Architecture:
//   AudioManager is an ObservableObject owned by ContentView and passed
//   into SceneView and VisionView as an @EnvironmentObject. It owns all
//   AVAudioPlayer instances and handles crossfading between states.
//
// Audio layers:
//   · Ambience    — looping location drone, crossfades on location change
//   · Flame       — constant near-subliminal sacred flame loop
//   · Vision      — dissonant building drone, plays only during VisionView
//
// The Act IV silence:
//   When act 4 begins, the adyton ambience switches to a version with the
//   vision drone layer removed. Players who have been through several vision
//   sessions will feel the absence without being told about it.
//
// Expected audio files (all looping .mp3 or .caf in the main bundle):
//   ambience_sacred_spring   — water, stone, distant chant
//   ambience_adyton          — quiet drone with subtle flame presence
//   ambience_forecourt       — crowd hum, open air
//   ambience_quarters        — intimate silence, small room
//   ambience_priests_hall    — low stone resonance
//   ambience_adyton_act4     — adyton without the vision drone layer (the silence)
//   vision_drone             — dissonant, building, unresolved
//   flame                    — sacred flame loop, very quiet
//
// Usage:
//   // In ContentView:
//   @StateObject private var audio = AudioManager()
//   SceneView(engine: engine).environmentObject(audio)
//
//   // AudioManager observes engine state via explicit calls from SceneView:
//   audio.transitionToLocation(.adyton)
//   audio.beginVision()
//   audio.endVision()
//   audio.transitionToAct(4)

import AVFoundation
import SwiftUI
import Combine

// MARK: - AudioManager

@MainActor
class AudioManager: ObservableObject {

    // MARK: - Players

    private var ambiencePlayer: AVAudioPlayer?
    private var flamePlayer: AVAudioPlayer?
    private var visionPlayer: AVAudioPlayer?
    private var splashPlayer: AVAudioPlayer?
    private var actCardPlayer: AVAudioPlayer?

    // MARK: - State

    private var currentLocation: LocationID = .sacredSpring
    private var currentAct: Int = 1
    private var visionActive: Bool = false

    // Master volume multipliers — adjust to taste during mixing
    private let flameVolume: Float  = 0.18   // Base flame volume
    private let visionVolume: Float = 0.70

    /// Location-aware ambience volume.
    private func ambienceVolume (for location: LocationID) -> Float {
        switch location {
        case .marasQuarters:   return 0.50  // Near-silent room — needs to dominate clearly
        case .templeForecourt: return 0.05  // Outdoor crowd — loud and present
        case .priestsHall:     return 0.60  // Dense drone
        case .sacredSpring:    return 0.60  // Water recording
        case .adyton:          return 0.55  // Sacred drone — flame most present here
        }
    }

    /// Location-aware flame volume.
    /// The flame is only audible in spaces where it is physically present
    /// or ritually significant — the adyton and the sacred spring.
    /// Everywhere else it fades to silence.
    private func targetFlameVolume (for location: LocationID) -> Float {
        switch location {
        case .adyton:        return flameVolume       // Full presence — the flame is right there
        case .sacredSpring:  return flameVolume * 0.5 // Faint — ritual space, flame nearby
        case .marasQuarters: return 0                 // Private room — no flame
        case .templeForecourt: return 0               // Outdoors — no flame
        case .priestsHall:   return 0                 // Political space — no flame
        }
    }

    // Crossfade duration in seconds
    private let crossfadeDuration: TimeInterval = 2.0
    private let visionFadeDuration: TimeInterval = 1.4

    // MARK: - Init

    init () {
        configureAudioSession ()
        prepareFlameLoop ()
        // Ambience does NOT start here — AudioManager is created at app launch
        // before the splash screen, so starting ambience here would play water
        // sounds underneath the title screen. Call startGameAudio() instead
        // when the game actually begins (from SceneView.onAppear).
    }

    // MARK: - Public API

    /// Start location ambience when the game begins.
    /// Call from SceneView.onAppear — not from init, which runs during splash.
    func startGameAudio () {
        crossfadeAmbience (to: ambienceFilename (for: .sacredSpring, act: 1), location: .sacredSpring)
    }

    /// Call when the player enters a new location.
    /// Crossfades from the current ambience to the new one.
    /// If a vision is active, just records the new location — ambience
    /// will crossfade to the correct file when endVision() is called.
    func transitionToLocation (_ location: LocationID) {
        guard location != currentLocation else { return }
        currentLocation = location
        guard !visionActive else { return }
        crossfadeAmbience (to: ambienceFilename (for: location, act: currentAct), location: location)
        // Crossfade flame to the correct level for this location
        fadeVolume (of: flamePlayer, to: targetFlameVolume (for: location), duration: crossfadeDuration)
    }

    /// Call when the act number changes.
    /// Act 4 switches the adyton to its silent variant.
    func transitionToAct (_ act: Int) {
        currentAct = act
        if currentLocation == .adyton {
            crossfadeAmbience (to: ambienceFilename (for: .adyton, act: act), location: .adyton)
        }
    }

    /// Call when VisionView is about to be presented.
    func beginVision () {
        guard !visionActive else { return }
        visionActive = true

        // Fade ambience down to 15% of its current location volume
        let reducedVolume = ambienceVolume (for: currentLocation) * 0.15
        fadeVolume (of: ambiencePlayer, to: reducedVolume, duration: visionFadeDuration)
        fadeVolume (of: flamePlayer, to: 0, duration: visionFadeDuration)

        startVisionDrone ()
    }

    /// Call after VisionView dismisses and the colour transition back begins.
    func endVision () {
        guard visionActive else { return }
        visionActive = false

        fadeVolume (of: visionPlayer, to: 0, duration: visionFadeDuration) { [weak self] in
            self?.visionPlayer?.stop ()
            self?.visionPlayer = nil
        }

        crossfadeAmbience (to: ambienceFilename (for: currentLocation, act: currentAct), location: currentLocation)
        fadeVolume (of: flamePlayer, to: targetFlameVolume (for: currentLocation), duration: visionFadeDuration)
    }

    /// Call on game reset / new game to reset audio state.
    /// Does NOT start ambience — startGameAudio() handles that when
    /// the act card is dismissed and the game actually begins.
    func resetAudio () {
        visionActive = false
        currentAct = 1
        currentLocation = .sacredSpring

        // Stop and clear all players
        ambiencePlayer?.stop ()
        ambiencePlayer = nil
        visionPlayer?.stop ()
        visionPlayer = nil

        // Keep flame playing but silence it until game starts
        flamePlayer?.setVolume (0, fadeDuration: 0.3)
    }

    /// Play the splash screen music — fades in gently.
    /// Call from SplashScreen.onAppear.
    func playSplashMusic () {
        guard let player = makePlayer (filename: "music_splash") else { return }
        player.numberOfLoops = -1
        player.volume = 0
        player.play ()
        player.setVolume (0.75, fadeDuration: 2.5)
        splashPlayer = player
    }

    /// Stop splash music — fades out over the given duration.
    /// Call when the player taps Begin / Continue.
    func stopSplashMusic (fadeDuration: TimeInterval = 0.8) {
        guard let player = splashPlayer else { return }
        player.setVolume (0, fadeDuration: fadeDuration)
        DispatchQueue.main.asyncAfter (deadline: .now () + fadeDuration + 0.1) { [weak self] in
            self?.splashPlayer?.stop ()
            self?.splashPlayer = nil
        }
    }

    /// Play the act card music — a single short piece, plays once and stops.
    /// Call from ActTitleCard.onAppear.
    func playActCardMusic () {
        guard let player = makePlayer (filename: "music_act_card") else { return }
        player.numberOfLoops = 0   // Play once only
        player.volume = 0
        player.play ()
        player.setVolume (0.80, fadeDuration: 1.0)
        actCardPlayer = player
    }

    /// Stop act card music — fades out.
    /// Call when the act card is dismissed.
    func stopActCardMusic (fadeDuration: TimeInterval = 0.6) {
        guard let player = actCardPlayer else { return }
        player.setVolume (0, fadeDuration: fadeDuration)
        DispatchQueue.main.asyncAfter (deadline: .now () + fadeDuration + 0.1) { [weak self] in
            self?.actCardPlayer?.stop ()
            self?.actCardPlayer = nil
        }
    }

    /// Fade game ambience and flame to silence — call when act card appears
    /// so the card music plays without competition from the game audio.
    func pauseGameAudio (fadeDuration: TimeInterval = 0.8) {
        ambiencePlayer?.setVolume (0, fadeDuration: fadeDuration)
        flamePlayer?.setVolume (0, fadeDuration: fadeDuration)
    }

    /// Restore game ambience and flame after act card dismisses.
    func resumeGameAudio (fadeDuration: TimeInterval = 1.2) {
        ambiencePlayer?.setVolume (ambienceVolume (for: currentLocation), fadeDuration: fadeDuration)
        flamePlayer?.setVolume (targetFlameVolume (for: currentLocation), fadeDuration: fadeDuration)
    }

    // MARK: - Private: Setup

    private func configureAudioSession () {
        do {
            try AVAudioSession.sharedInstance ().setCategory (
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance ().setActive (true)
        } catch {
            print ("PYTHIA Audio: session configuration failed — \(error)")
        }
    }

    /// Prepare the flame loop immediately — it plays throughout the entire game.
    private func prepareFlameLoop () {
        guard let player = makePlayer (filename: "flame") else { return }
        player.numberOfLoops = -1
        player.volume = 0
        player.play ()
        // Fade in to the correct level for the starting location (sacredSpring)
        player.setVolume (targetFlameVolume (for: .sacredSpring), fadeDuration: 3.0)
        flamePlayer = player
    }

    // MARK: - Private: Ambience

    private func crossfadeAmbience (to filename: String, location: LocationID) {
        let targetVolume = ambienceVolume (for: location)

        let incoming = makePlayer (filename: filename)
        incoming?.numberOfLoops = -1
        incoming?.volume = 0
        incoming?.play ()

        let outgoing = ambiencePlayer
        outgoing?.setVolume (0, fadeDuration: crossfadeDuration)

        incoming?.setVolume (targetVolume, fadeDuration: crossfadeDuration)

        DispatchQueue.main.asyncAfter (deadline: .now () + crossfadeDuration + 0.1) {
            outgoing?.stop ()
        }

        ambiencePlayer = incoming
    }

    /// Returns the correct ambience filename for a given location and act.
    /// Act 4 adyton uses a special variant — the one without the vision drone.
    private func ambienceFilename (for location: LocationID, act: Int) -> String {
        switch location {
        case .sacredSpring:
            return "ambience_sacred_spring"
        case .adyton:
            return act >= 4 ? "ambience_adyton_act4" : "ambience_adyton"
        case .templeForecourt:
            return "ambience_forecourt"
        case .marasQuarters:
            return "ambience_quarters"
        case .priestsHall:
            return "ambience_priests_hall"
        }
    }

    // MARK: - Private: Vision Drone

    private func startVisionDrone () {
        guard let player = makePlayer (filename: "vision_drone") else { return }
        player.numberOfLoops = -1
        player.volume = 0
        player.play ()
        player.setVolume (visionVolume, fadeDuration: visionFadeDuration)
        visionPlayer = player
    }

    // MARK: - Private: Utilities

    /// Create an AVAudioPlayer for a bundled audio file.
    /// Returns nil silently if the file is missing — audio is non-critical.
    private func makePlayer (filename: String) -> AVAudioPlayer? {
        // Try .mp3 first, then .caf, then .m4a
        let extensions = ["mp3", "caf", "m4a"]
        for ext in extensions {
            if let url = Bundle.main.url (forResource: filename, withExtension: ext) {
                do {
                    return try AVAudioPlayer (contentsOf: url)
                } catch {
                    print ("PYTHIA Audio: failed to load \(filename).\(ext) — \(error)")
                }
            }
        }
        // File not found — degrade gracefully
        print ("PYTHIA Audio: '\(filename)' not found in bundle — skipping")
        return nil
    }

    /// Fade a player's volume over a duration, with optional completion.
    private func fadeVolume (
        of player: AVAudioPlayer?,
        to volume: Float,
        duration: TimeInterval,
        completion: (() -> Void)? = nil
    ) {
        guard let player else {
            completion? ()
            return
        }
        player.setVolume (volume, fadeDuration: duration)
        if let completion {
            DispatchQueue.main.asyncAfter (deadline: .now () + duration) {
                completion ()
            }
        }
    }
}
