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
    case narrator                       // Environmental / scene description

    var displayName: String {
        switch self {
        case .mara:       return "MARA"
        case .demetrios:  return "DEMETRIOS"
        case .lyra:       return "LYRA"
        case .nikomedes:  return "NIKOMEDES"
        case .leonidas:   return "LEONIDAS"
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
        case .narrator:   return Color (red: 0.55, green: 0.50, blue: 0.42)   // muted stone
        }
    }

    /// Asset catalogue name for portrait image — nil if no portrait exists yet
    var portraitAssetName: String? {
        switch self {
        case .demetrios:  return "portrait_demetrios"
        case .lyra:       return "portrait_lyra"
        case .nikomedes: return "portrait_nikomedes"
        case .leonidas: return "portrait_leonidas"
        default:          return nil
        }
    }
}

/// A player choice within a dialogue node
struct DialogueChoice: Identifiable {
    let id: String
    let text: String
    let requires: KnowledgeFlag?        // nil = always visible
    let leadsTo: String                 // next node ID
    let teaches: KnowledgeFlag?         // flag learned on selection
    let axisNote: String?               // debug only — describes axis impact
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
enum LocationID: String {
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

    /// The journal — accumulated narrative entries the player can read
    @Published private(set) var journalEntries: [JournalEntry] = []

    // MARK: Private

    private let knowledge: KnowledgeState
    private var nodeGraph: [String: DialogueNode] = [:]

    // MARK: Init

    init (nodes: [DialogueNode], knowledge: KnowledgeState, startNodeID: String? = nil) {
        self.knowledge = knowledge

        // Build lookup graph from array
        for node in nodes {
            nodeGraph[node.id] = node
        }

        // Start at the first node unless specified
        let firstID = startNodeID ?? nodes.first?.id ?? ""
        advance (to: firstID)
    }

    // MARK: - Advancing

    /// Advance to a specific node ID. Called by tap-to-advance and choice selection.
    func advance (to nodeID: String) {
        guard let node = nodeGraph[nodeID] else {
            return
        }

        // Learn the flag this node teaches, if any
        if let flag = node.teaches {
            knowledge.learn (flag)
        }

        // Fire any trigger
        if let trigger = node.trigger {
            handleTrigger (trigger)
        }

        withAnimation (.easeInOut (duration: 0.4)) {
            currentNode = node
        }

        // Auto-save after every node advance
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

    /// Called when the player selects a dialogue choice
    func selectChoice (_ choice: DialogueChoice) {
        // Learn the flag this choice teaches
        if let flag = choice.teaches {
            knowledge.learn (flag)
        }
        // Record in dialogue history
        knowledge.recordDialogueChoice (
            sceneID: currentNode?.id ?? "unknown",
            chosenOptionID: choice.id
        )
        advance (to: choice.leadsTo)
    }

    /// Returns only the choices available given current knowledge state
    func availableChoices (for node: DialogueNode) -> [DialogueChoice] {
        guard let choices = node.choices else { return [] }
        return choices.filter { choice in
            guard let required = choice.requires else { return true }
            return knowledge.knows (required)
        }
    }

    // MARK: - Vision Session Handling

    /// Called by SceneView when the vision session completes
    func visionSessionCompleted (sessionID: String, selectedFragmentIDs: [String]) {
        // Record in knowledge
        knowledge.recordVisionInterpretation (
            sessionID: sessionID,
            offeredFragmentIDs: pendingVisionSession?.fragments.map { $0.id } ?? [],
            selectedFragmentIDs: selectedFragmentIDs
        )
        pendingVisionSession = nil

        // Resume from the post-vision node (convention: sessionID + "_return")
        let returnNodeID = sessionID + "_return"
        if nodeGraph[returnNodeID] != nil {
            advance (to: returnNodeID)
        }
    }

    // MARK: - Journal

    func addJournalEntry (_ entry: JournalEntry) {
        journalEntries.append (entry)
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

        case .openJournal (let entry):
            addJournalEntry (entry)

        case .actTransition (let act):
            knowledge.currentAct = act
            currentActNumber = act

        case .endGame:
            break   // Parent view handles this
        }
    }
}

// MARK: - Journal Entry

struct JournalEntry: Identifiable {
    let id: String
    let title: String
    let body: String
    let actNumber: Int
}
