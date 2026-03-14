// KnowledgeState.swift
// PYTHIA
//
// The hidden knowledge model — tracks everything Mara has learned,
// seen, and experienced across the playthrough.
//
// This model is never shown to the player as a list or inventory.
// It surfaces organically: a new dialogue option appears; a journal
// entry updates; Mara notices something she would have missed before.
//
// Two primary axes feed into the ending calculation:
//   faithAxis      — does Mara still believe Apollo spoke through her?
//   integrityAxis  — did she ultimately speak truth regardless of cost?
//
// Usage:
//   let state = KnowledgeState ()
//   state.learn (.metDemetrios)
//   state.recordVisionInterpretation (sessionID: "harvest", selectedFragmentIDs: ["rain", "wait"])
//   state.applyDialogueChoice (.toldLeonidasTruth)
//   let ending = state.resolveEnding ()

import Foundation
import Combine

// MARK: - Knowledge Flags

/// Every discrete fact or impression Mara can accumulate.
/// Add new cases as Acts II–IV are written — the enum grows with the story.
enum KnowledgeFlag: String, Codable, CaseIterable {

    // --- Act I: The Voice ---
    case completedPurificationRitual        // Saw the opening ritual sequence
    case metDemetrios                       // First meeting with the Head Priest
    case metLyra                            // Met her attendant
    case deliveredHarvestProphecy           // Completed the first vision session
    case observedNikomedosArrival           // Saw the Athenian delegation arrive
    case readJournalEntry_beforeTemple      // Read optional backstory journal entry
    case demetriosExplainedPhilosophy       // Heard his mentor speech in Act I

    // --- Act II: The Delegations ---
    case receivedAthenianDelegation         // Sat with the Athenian delegation
    case receivedThebanDelegation           // Sat with the Theban delegation
    case receivedAegeanDelegation           // Sat with the small island city-state
    case witnessedDemetriosRedirectProphecy // Saw him reframe the burning ships vision
    case nikomedosApproachedPrivately       // He came to Mara with his suspicion
    case toldNikomedosTruth                 // Confirmed his suspicion to him
    case toldNikomedesFalsehood             // Denied his suspicion
    case toldNikomedesNothing               // Stayed silent — his trust is uncertain
    case knowsDelphineFundingArrangement    // Understands the city-state donation politics
    case overheardPriestsHall               // Eavesdropped on Demetrios in the Priests' Hall

    // --- Act III: The Pass ---
    case leonidasArrived                    // Leonidas reached Delphi
    case receivedLeonidasVision             // The full overwhelming vision of Thermopylae
    case demetriosToldHerWhatToSay          // Received his explicit instruction before the session
    case toldLeonidasTruth                  // Spoke the true prophecy — death, meaning, go
    case toldLeonidasDemetriosVersion       // Delivered the managed, false prophecy
    case toldLeonidasInRiddles              // Gave the authentic ambiguous Oracle response
    case leonidasUnderstoodRiddle           // He interpreted the riddle correctly (if riddle path)
    case leonidasMisreadRiddle              // He interpreted it incorrectly
    case confrontedDemetriosDirectly        // Had the open confrontation with him
    case avoidedDemetriosConflict           // Navigated around confrontation

    // --- Act IV: The Silence ---
    case visionsHaveStopped                 // The adyton went silent
    case fabricatedProphecyWithoutVision    // Invented prophecy from her own knowledge
    case refusedToSpeakWithoutVision        // Told a supplicant she had nothing
    case drewOnAccumulatedKnowledge         // Used what she had learned to speak honestly
    case admittedSilenceToKeyPerson         // Confessed the silence to someone who mattered
    case lyraInDanger                       // Lyra became endangered by prior events
    case savedLyra                          // Protected her
    case failedToSaveLyra                   // Could not, or did not
    case nikomedosReturned                  // He came back in Act IV
    case nikomedosWasAlly                   // He helped her (requires earlier trust)
    case nikomedosWasNeutral                // He was present but uncommitted
    case demetriosWasAllyInActIV            // He helped her (specific path)
    case demetriosWasEnemyInActIV           // He moved against her

    // --- Faith markers (accumulate across all acts) ---
    case doubtedDivineOriginOfVision        // Internal moment of doubt in journal/adyton
    case feltGenuinelyChosenByApollo        // Moment of genuine spiritual conviction
    case concludedVisionsWereHerOwn         // Crossed the line to disbelief
    case maintainedFaithThroughSilence      // Kept believing even when the visions stopped

    // --- Integrity markers ---
    case spokeAgainstDemetriosWishes        // Defied him in a significant prophecy moment
    case capitulatedToDemetriosWishes       // Went along with what he wanted
    case usedOracularAmbiguityAsShield      // Hid behind tradition to avoid truth
    case spokeDirectTruthAtPersonalCost     // Said what was true knowing the consequence
}

// MARK: - Vision Session Record

/// A record of one complete vision session — which fragments were offered,
/// which the player selected, and when it happened.
struct VisionSessionRecord: Codable {
    let sessionID: String           // e.g. "harvest", "leonidas", "aegean_fleet"
    let actNumber: Int              // Which act this occurred in
    let offeredFragmentIDs: [String]
    let selectedFragmentIDs: [String]
    let timestamp: Date
}

// MARK: - Dialogue Choice Record

/// A record of a significant dialogue choice — what was said and in what context.
/// Used for journal reconstruction and potential Act IV callbacks.
struct DialogueChoiceRecord: Codable {
    let sceneID: String             // e.g. "nikomedes_private_approach"
    let chosenOptionID: String      // e.g. "told_truth", "stayed_silent"
    let actNumber: Int
    let timestamp: Date
}

// MARK: - Ending Axes

/// The two emotional axes that determine which ending Mara reaches.
/// Values accumulate as signed integers — positive moves toward the
/// "intact" pole, negative toward the "broken" pole.
struct EndingAxes: Codable {
    var faith: Int = 0             // Positive = Apollo spoke. Negative = she was always alone.
    var integrity: Int = 0         // Positive = spoke truth. Negative = compromised.

    // Resolved poles for ending calculation
    var faithIntact: Bool { faith >= 0 }
    var integrityIntact: Bool { integrity >= 0 }
}

// MARK: - Ending

enum Ending: String, Codable {
    case theProphet      // Faith intact + Integrity intact
    case theMartyr       // Faith intact + Integrity broken
    case thePhilosopher  // Faith broken + Integrity intact
    case theHollow       // Faith broken + Integrity broken

    var title: String {
        switch self {
        case .theProphet:     return "The Prophet"
        case .theMartyr:      return "The Martyr"
        case .thePhilosopher: return "The Philosopher"
        case .theHollow:      return "The Hollow"
        }
    }

    var flameDescription: String {
        switch self {
        case .theProphet:     return "The flame burns steadily."
        case .theMartyr:      return "The flame flickers."
        case .thePhilosopher: return "The flame burns."
        case .theHollow:      return "The flame goes dark."
        }
    }
}

// MARK: - KnowledgeState

/// The central model for everything Mara knows and has experienced.
/// Persisted via Codable — saved after every scene transition.
class KnowledgeState: ObservableObject {
    // MARK: Core State

    /// All flags Mara has accumulated
    @Published private(set) var learnedFlags: Set<KnowledgeFlag> = []

    /// Ordered history of vision sessions
    @Published private(set) var visionHistory: [VisionSessionRecord] = []

    /// Ordered history of significant dialogue choices
    @Published private(set) var dialogueHistory: [DialogueChoiceRecord] = []

    /// The two ending axes — updated as choices are made
    @Published private(set) var axes: EndingAxes = EndingAxes ()

    /// Current act (1–4) — updated by the narrative engine
    @Published var currentAct: Int = 1

    /// The last node ID the player reached — used to resume on relaunch
    @Published var lastNodeID: String? = nil

    // MARK: - Knowledge Accumulation

    /// Learn a new flag. Safe to call multiple times — duplicates are ignored.
    func learn (_ flag: KnowledgeFlag) {
        guard !learnedFlags.contains (flag) else { return }
        learnedFlags.insert (flag)
        applyAxisImpact (for: flag)
    }

    /// Check if Mara knows something — used by dialogue system to gate options.
    func knows (_ flag: KnowledgeFlag) -> Bool {
        learnedFlags.contains (flag)
    }

    /// Check if Mara knows ALL of a set of flags — for complex dialogue gates.
    func knowsAll (_ flags: KnowledgeFlag...) -> Bool {
        flags.allSatisfy { learnedFlags.contains ($0) }
    }

    /// Check if Mara knows ANY of a set of flags.
    func knowsAny (_ flags: KnowledgeFlag...) -> Bool {
        flags.contains { learnedFlags.contains ($0) }
    }

    // MARK: - Vision Recording

    /// Record the result of a vision session and learn any associated flags.
    func recordVisionInterpretation (
        sessionID: String,
        offeredFragmentIDs: [String],
        selectedFragmentIDs: [String]
    ) {
        let record = VisionSessionRecord (
            sessionID: sessionID,
            actNumber: currentAct,
            offeredFragmentIDs: offeredFragmentIDs,
            selectedFragmentIDs: selectedFragmentIDs,
            timestamp: Date ()
        )
        visionHistory.append (record)
    }

    /// Check what the player selected in a past vision session.
    /// Used when a fragment resurfaces with new meaning in Act IV.
    func selectedFragments (inSession sessionID: String) -> [String] {
        visionHistory
            .first { $0.sessionID == sessionID }?
            .selectedFragmentIDs ?? []
    }

    // MARK: - Dialogue Recording

    /// Record a significant dialogue choice.
    func recordDialogueChoice (sceneID: String, chosenOptionID: String) {
        let record = DialogueChoiceRecord (
            sceneID: sceneID,
            chosenOptionID: chosenOptionID,
            actNumber: currentAct,
            timestamp: Date ()
        )
        dialogueHistory.append (record)
    }

    // MARK: - Ending Resolution

    /// Resolve the ending based on accumulated axis values.
    /// Call this when entering the Epilogue.
    func resolveEnding () -> Ending {
        switch (axes.faithIntact, axes.integrityIntact) {
        case (true,  true):  return .theProphet
        case (true,  false): return .theMartyr
        case (false, true):  return .thePhilosopher
        case (false, false): return .theHollow
        }
    }

    // MARK: - Axis Impact

    /// Each flag has a defined impact on the ending axes.
    /// This is the hidden scoring system — the player never sees these numbers.
    private func applyAxisImpact (for flag: KnowledgeFlag) {
        switch flag {

        // --- Faith axis: positive (Apollo spoke through her) ---
        case .feltGenuinelyChosenByApollo:      axes.faith += 2
        case .maintainedFaithThroughSilence:    axes.faith += 2
        case .demetriosExplainedPhilosophy:     axes.faith += 1  // She heard a case for the system

        // --- Faith axis: negative (she was always alone) ---
        case .doubtedDivineOriginOfVision:      axes.faith -= 1
        case .concludedVisionsWereHerOwn:       axes.faith -= 3
        case .visionsHaveStopped:               axes.faith -= 1  // The silence is destabilising

        // --- Integrity axis: positive (she spoke truth) ---
        case .toldLeonidasTruth:                axes.integrity += 3
        case .spokeAgainstDemetriosWishes:      axes.integrity += 2
        case .spokeDirectTruthAtPersonalCost:   axes.integrity += 2
        case .toldNikomedosTruth:               axes.integrity += 1
        case .drewOnAccumulatedKnowledge:       axes.integrity += 1
        case .admittedSilenceToKeyPerson:       axes.integrity += 2
        case .refusedToSpeakWithoutVision:      axes.integrity += 1

        // --- Integrity axis: negative (she compromised) ---
        case .toldLeonidasDemetriosVersion:     axes.integrity -= 3
        case .capitulatedToDemetriosWishes:     axes.integrity -= 2
        case .fabricatedProphecyWithoutVision:  axes.integrity -= 2
        case .usedOracularAmbiguityAsShield:    axes.integrity -= 1
        case .toldNikomedesFalsehood:           axes.integrity -= 1

        // --- Riddle path — ambiguous impact on both axes ---
        case .toldLeonidasInRiddles:            axes.integrity -= 1  // Partially a compromise
        case .leonidasUnderstoodRiddle:         axes.integrity += 1  // She meant well and it landed
        case .leonidasMisreadRiddle:            axes.integrity -= 1  // It cost him

        default:
            break  // Most flags are narrative facts with no direct axis impact
        }
    }

    // MARK: - Persistence

    /// The save file URL in the app's documents directory.
    private static var saveURL: URL {
        FileManager.default.urls (for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent ("pythia_save.json")
    }

    /// True if a save file exists on disk.
    static var hasSave: Bool {
        FileManager.default.fileExists (atPath: saveURL.path)
    }

    /// Persist the current state to disk.
    /// Called automatically after every node advance.
    func save () {
        let snapshot = SaveSnapshot (
            learnedFlags: Array (learnedFlags),
            axes: axes,
            currentAct: currentAct,
            lastNodeID: lastNodeID,
            visionHistory: visionHistory,
            dialogueHistory: dialogueHistory
        )
        do {
            let data = try JSONEncoder ().encode (snapshot)
            try data.write (to: Self.saveURL, options: .atomic)
        } catch {
            // Save failures are silent — the game is still playable
            print ("PYTHIA: save failed — \(error)")
        }
    }

    /// Load state from disk into this instance.
    /// Call once on init when resuming a saved game.
    func load () {
        guard let data = try? Data (contentsOf: Self.saveURL),
              let snapshot = try? JSONDecoder ().decode (SaveSnapshot.self, from: data)
        else { return }

        learnedFlags = Set (snapshot.learnedFlags)
        axes = snapshot.axes
        currentAct = snapshot.currentAct
        lastNodeID = snapshot.lastNodeID
        visionHistory = snapshot.visionHistory
        dialogueHistory = snapshot.dialogueHistory
    }

    /// Erase the save file — called when starting a New Game.
    static func deleteSave () {
        try? FileManager.default.removeItem (at: saveURL)
    }
}

// MARK: - Save Snapshot

/// Codable snapshot of all persisted state.
/// Kept separate from KnowledgeState so the @Published
/// properties don't need to be Codable themselves.

private struct SaveSnapshot: Codable {
    let learnedFlags: [KnowledgeFlag]
    let axes: EndingAxes
    let currentAct: Int
    let lastNodeID: String?
    let visionHistory: [VisionSessionRecord]
    let dialogueHistory: [DialogueChoiceRecord]
}

// MARK: - KnowledgeState Debug Extension

extension KnowledgeState {
    /// Returns a summary of current state — for debug builds only.
    /// Never expose this to the player.
    var debugSummary: String {
        """
        === KnowledgeState Debug ===
        Act: \(currentAct)
        Flags (\(learnedFlags.count)): \(learnedFlags.map { $0.rawValue }.sorted ().joined (separator: ", "))
        Faith: \(axes.faith) (\(axes.faithIntact ? "intact" : "broken"))
        Integrity: \(axes.integrity) (\(axes.integrityIntact ? "intact" : "broken"))
        Vision sessions: \(visionHistory.count)
        Projected ending: \(resolveEnding ().title)
        ============================
        """
    }
}
