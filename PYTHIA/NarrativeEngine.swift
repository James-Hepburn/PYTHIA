// NarrativeEngine.swift
// PYTHIA
//
// The narrative engine manages the story graph — advancing through
// DialogueNodes, handing off to VisionView when a vision session
// is triggered, and keeping KnowledgeState in sync throughout.
//
// All story content lives in data (ActI.swift, ActII.swift, etc.)
// not here. The engine is content-agnostic — it just runs the graph.
//
// Vision → Dialogue pipeline:
//   1. A node fires .beginVisionSession — VisionView is presented.
//   2. Player selects exactly 3 fragments and confirms.
//   3. visionSessionCompleted() stores those 3 IDs in activeVisionSelections.
//   4. The engine advances to the [sessionID]_return node.
//   5. The next node with choices uses DialogueChoice.sourceFragmentID.
//      availableChoices() filters to only the 3 choices whose fragment IDs
//      the player selected — those become the only available options.
//   6. After that choice node is resolved, clearVisionSelections() is called
//      automatically, resetting for the next session.
//
// Usage (from a parent view):
//   @StateObject var engine = NarrativeEngine (
//       nodes: ActI.nodes,
//       knowledge: knowledgeState
//   )
//   SceneView (engine: engine)

import SwiftUI
import Combine

// MARK: - Dialogue Models

/// A single line or beat of the story — the atomic unit of narrative.
struct DialogueNode: Identifiable {
    let id: String
    let speaker: Speaker?               // nil = narration / Mara's internal voice
    let text: String
    let choices: [DialogueChoice]?      // nil = tap anywhere to advance
    let nextNodeID: String?             // Used when choices is nil
    let trigger: NodeTrigger?           // Special action this node fires
    let teaches: KnowledgeFlag?         // Flag learned on reaching this node
}

/// Who is speaking — controls text panel style
enum Speaker {
    case mara
    case demetrios
    case lyra
    case nikomedes
    case leonidas
    case pausanias
    case narrator                       // Environmental / scene description

    var displayName: String {
        switch self {
        case .mara:       return "MARA"
        case .demetrios:  return "DEMETRIOS"
        case .lyra:       return "LYRA"
        case .nikomedes:  return "NIKOMEDES"
        case .leonidas:   return "LEONIDAS"
        case .pausanias:  return "PAUSANIAS"
        case .narrator:   return ""
        }
    }

    /// Warm ochre palette — each speaker has a distinct accent
    var accentColor: Color {
        switch self {
        case .mara:       return Color (red: 0.85, green: 0.72, blue: 0.50)   // warm gold
        case .demetrios:  return Color (red: 0.70, green: 0.55, blue: 0.40)   // deep ochre
        case .lyra:       return Color (red: 0.78, green: 0.68, blue: 0.55)   // pale tan
        case .nikomedes:  return Color (red: 0.65, green: 0.60, blue: 0.50)   // grey-ochre
        case .leonidas:   return Color (red: 0.80, green: 0.35, blue: 0.25)   // Spartan red
        case .pausanias:  return Color (red: 0.49, green: 0.52, blue: 0.69)   // Theban blue
        case .narrator:   return Color (red: 0.55, green: 0.50, blue: 0.42)   // muted stone
        }
    }

    /// Asset catalogue name for portrait image — nil if no portrait exists yet
    var portraitAssetName: String? {
        switch self {
        case .demetrios:  return "portrait_demetrios"
        case .lyra:       return "portrait_lyra"
        case .nikomedes:  return "portrait_nikomedes"
        case .leonidas:   return "portrait_leonidas"
        case .pausanias:  return "portrait_pausanias"
        default:          return nil
        }
    }
}

/// A player choice within a dialogue node.
///
/// Vision-derived choices: set sourceFragmentID to the Fragment.id whose
/// dialogueOption this choice represents. availableChoices() will only
/// surface this choice if that fragment is in activeVisionSelections.
///
/// Non-vision choices: leave sourceFragmentID nil. They behave exactly
/// as before — gated only by `requires` knowledge flag, if set.
struct DialogueChoice: Identifiable {
    let id: String
    let text: String
    let requires: KnowledgeFlag?        // nil = always visible (subject to fragment gate below)
    let leadsTo: String                 // next node ID
    let teaches: KnowledgeFlag?         // flag learned on selection
    let axisNote: String?               // debug only — describes axis impact

    /// The Fragment.id this choice is derived from.
    /// When set, this choice is only available if that fragment was selected
    /// in the most recent vision session. nil = standard dialogue choice.
    let sourceFragmentID: String?

    // Convenience init that keeps sourceFragmentID optional at the call site
    init (
        id: String,
        text: String,
        requires: KnowledgeFlag? = nil,
        leadsTo: String,
        teaches: KnowledgeFlag? = nil,
        axisNote: String? = nil,
        sourceFragmentID: String? = nil
    ) {
        self.id = id
        self.text = text
        self.requires = requires
        self.leadsTo = leadsTo
        self.teaches = teaches
        self.axisNote = axisNote
        self.sourceFragmentID = sourceFragmentID
    }
}

/// Special triggers a node can fire — handed back to the parent view
enum NodeTrigger {
    case beginVisionSession (sessionID: String, fragments: [Fragment])
    case enterLocation (LocationID)
    case openJournal (JournalEntry)
    case actTransition (toAct: Int)
    case endGame
}

/// Locations in the sanctuary — controls background art
enum LocationID: String, Codable {
    case sacredSpring    = "sacred_spring"
    case adyton          = "adyton"
    case templeForecourt = "temple_forecourt"
    case marasQuarters   = "maras_quarters"
    case priestsHall     = "priests_hall"
}

// MARK: - NarrativeEngine

@MainActor
class NarrativeEngine: ObservableObject {
    // MARK: Published State

    /// The node currently being displayed
    @Published private(set) var currentNode: DialogueNode?

    /// Current location — drives background art in SceneView
    @Published private(set) var currentLocation: LocationID = .sacredSpring

    /// True when a vision session should be presented
    @Published private(set) var pendingVisionSession: (sessionID: String, fragments: [Fragment])?

    /// True during scene transitions (fade out/in)
    @Published private(set) var isTransitioning: Bool = false

    /// Current act number — observed by SceneView to trigger title card
    @Published private(set) var currentActNumber: Int = 1

    /// True while a save is being loaded — suppresses SceneView's act card observer
    @Published private(set) var isLoadingGame: Bool = false

    /// The journal — passthrough to KnowledgeState so entries persist with saves.
    @Published private(set) var journalEntries: [JournalEntry] = []

    // MARK: Private

    private let knowledge: KnowledgeState
    private var nodeGraph: [String: DialogueNode] = [:]

    /// The fragment IDs the player selected in the most recent vision session.
    /// These gate which DialogueChoices are available in the prophecy node that follows.
    /// Cleared automatically after the first vision-derived choice is made.
    private var activeVisionSelections: Set<String> = []

    // MARK: Init

    init (nodes: [DialogueNode], knowledge: KnowledgeState, startNodeID: String? = nil) {
        self.knowledge = knowledge

        for node in nodes {
            nodeGraph[node.id] = node
        }

        // ContentView controls start via resetToStart() or loadSave()
    }

    // MARK: - Advancing

    /// Advance to a specific node ID. Called by tap-to-advance and choice selection.
    func advance (to nodeID: String) {
        guard let node = nodeGraph[nodeID] else {
            return
        }

        if let flag = node.teaches {
            knowledge.learn (flag)
        }

        if let trigger = node.trigger {
            handleTrigger (trigger)
        }

        withAnimation (.easeInOut (duration: 0.4)) {
            currentNode = node
        }

        knowledge.lastNodeID = node.id
        knowledge.save ()
    }

    /// Called when the player taps to advance (no choices)
    func tapAdvance () {
        guard let node = currentNode,
              node.choices == nil,
              let nextID = node.nextNodeID else { return }
        advance (to: nextID)
    }

    /// Called when the player selects a dialogue choice.
    /// Clears activeVisionSelections after a vision-derived choice is made —
    /// the vision vocabulary is consumed once the prophecy is spoken.
    func selectChoice (_ choice: DialogueChoice) {
        if let flag = choice.teaches {
            knowledge.learn (flag)
        }
        knowledge.recordDialogueChoice (
            sceneID: currentNode?.id ?? "unknown",
            chosenOptionID: choice.id
        )

        // If this was a vision-derived choice, the selection set has done its job
        if choice.sourceFragmentID != nil {
            clearVisionSelections ()
        }

        advance (to: choice.leadsTo)
    }

    /// Returns only the choices available given current knowledge state
    /// AND (for vision-derived choices) the active fragment selection.
    ///
    /// Filter logic:
    ///   1. If choice.requires is set, Mara must know that flag.
    ///   2. If choice.sourceFragmentID is set, that ID must be in activeVisionSelections.
    ///      This means only the 3 chosen fragments produce available choices.
    ///   3. If sourceFragmentID is nil, the choice is a standard dialogue option
    ///      and passes through unaffected by the vision gate.
    func availableChoices (for node: DialogueNode) -> [DialogueChoice] {
        guard let choices = node.choices else { return [] }
        return choices.filter { choice in
            // Knowledge gate
            if let required = choice.requires, !knowledge.knows (required) {
                return false
            }
            // Vision fragment gate
            if let fragmentID = choice.sourceFragmentID {
                return activeVisionSelections.contains (fragmentID)
            }
            return true
        }
    }

    // MARK: - Vision Session Handling

    /// Called by SceneView when the vision session completes.
    /// Stores the selected fragment IDs so the dialogue phase can filter choices.
    func visionSessionCompleted (sessionID: String, selectedFragmentIDs: [String]) {
        // Store selections — these gate the prophecy choices
        activeVisionSelections = Set (selectedFragmentIDs)

        knowledge.recordVisionInterpretation (
            sessionID: sessionID,
            offeredFragmentIDs: pendingVisionSession?.fragments.map { $0.id } ?? [],
            selectedFragmentIDs: selectedFragmentIDs
        )
        pendingVisionSession = nil

        let returnNodeID = sessionID + "_return"
        if nodeGraph[returnNodeID] != nil {
            advance (to: returnNodeID)
        }
    }

    /// Clear the active vision selections.
    /// Called automatically after a vision-derived choice is made.
    private func clearVisionSelections () {
        activeVisionSelections = []
    }

    // MARK: - Journal

    func addJournalEntry (_ entry: JournalEntry) {
        knowledge.addJournalEntry (entry)
        journalEntries = knowledge.journalEntries
    }

    // MARK: - Trigger Handling

    private func handleTrigger (_ trigger: NodeTrigger) {
        switch trigger {

        case .beginVisionSession (let sessionID, let fragments):
            pendingVisionSession = (sessionID, fragments)

        case .enterLocation (let location):
            withAnimation (.easeInOut (duration: 0.8)) {
                currentLocation = location
            }
            knowledge.lastLocation = location

        case .openJournal (let entry):
            addJournalEntry (entry)

        case .actTransition (let act):
            knowledge.currentAct = act
            currentActNumber = act

        case .endGame:
            break
        }
    }

    // MARK: - Save / Load / Reset

    func loadSave () {
        knowledge.load ()
        currentActNumber = knowledge.currentAct
        currentLocation = knowledge.lastLocation
        journalEntries = knowledge.journalEntries
        isLoadingGame = true
        let resumeID = knowledge.lastNodeID ?? "act1_prologue_01"
        advance (to: resumeID)
        isLoadingGame = false
    }

    func resetToStart () {
        currentActNumber = 1
        activeVisionSelections = []
        advance (to: "act1_prologue_01")
    }

    // MARK: - Ending Handling

    var resolvedEnding: Ending {
        knowledge.resolveEnding ()
    }

    func routeToEnding () {
        let ending = knowledge.resolveEnding ()
        switch ending {
        case .theProphet:     advance (to: "epilogue_ending_prophet_01")
        case .theMartyr:      advance (to: "epilogue_ending_martyr_01")
        case .thePhilosopher: advance (to: "epilogue_ending_philosopher_01")
        case .theHollow:      advance (to: "epilogue_ending_hollow_01")
        }
    }
}

// MARK: - Journal Entry

struct JournalEntry: Identifiable, Codable {
    let id: String
    let title: String
    let body: String
    let actNumber: Int
}
