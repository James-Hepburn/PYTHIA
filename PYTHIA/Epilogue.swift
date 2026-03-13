// Epilogue.swift
// PYTHIA
//
// The final scene — "The Flame".
// ~5 minutes of play.
//
// The GDD is explicit: the visual is identical across all four endings.
// Mara alone in the adyton, the sacred flame before her.
// What differs is everything she carries as she sits there.
//
// Structure:
//   · Approach — walking to the adyton one last time
//   · The Flame — sitting with it, the accumulated weight of the playthrough
//   · The Question — the single final choice: tend the flame, or let it burn
//   · The Ending — four distinct closing passages, resolved from KnowledgeState
//   · Credits beat — the last thing the player sees
//
// The engine resolves the ending automatically from the knowledge axes.
// The player's final tap choice (tend/let burn) is noted but does not
// change the ending — both options lead to the same resolved ending text.
// The weight is in the choosing, not the consequence.
//
// Connect: act4_close_end.nextNodeID = "epilogue_open_01"
// and pass + Epilogue.nodes to NarrativeEngine.
//
// NarrativeEngine change required: EndingView must be triggered by .endGame.
// See note at bottom of file.

import SwiftUI

enum Epilogue {
    static var nodes: [DialogueNode] {
        approach + theFlame + endings + credits
    }

    // MARK: - Approach

    static let approach: [DialogueNode] = [
        DialogueNode (
            id: "epilogue_open_01",
            speaker: .narrator,
            text: "The temple is quiet at this hour.\n\nThe forecourt is empty. The supplicants have gone home — to Corinth, to Athens, to islands in the Aegean, carrying whatever you gave them.\n\nYou walk toward the adyton alone.",
            choices: nil,
            nextNodeID: "epilogue_open_02",
            trigger: .enterLocation (.templeForecourt),
            teaches: nil
        ),

        DialogueNode (
            id: "epilogue_open_02",
            speaker: .narrator,
            text: "The Sacred Spring is still as you pass it. You do not stop to prepare. There is nothing left to prepare for.\n\nYou are going to sit with the flame.\n\nThat is all.",
            choices: nil,
            nextNodeID: "epilogue_open_03",
            trigger: .enterLocation (.sacredSpring),
            teaches: nil
        ),

        DialogueNode (
            id: "epilogue_open_03",
            speaker: .narrator,
            text: "The adyton receives you the way it always has — stone, smoke, darkness except for the single flame on its tripod.\n\nYou sit.\n\nYou have sat here so many times. It feels different now. You feel different now.",
            choices: nil,
            nextNodeID: "epilogue_flame_01",
            trigger: .enterLocation (.adyton),
            teaches: nil
        ),
    ]

    // MARK: - The Flame

    static let theFlame: [DialogueNode] = [
        DialogueNode (
            id: "epilogue_flame_01",
            speaker: .narrator,
            text: "The flame burns.\n\nIt has burned here every day of your tenure, every day before it, every day you can remember being told about this place. It will burn after you. It does not know your name.",
            choices: nil,
            nextNodeID: "epilogue_flame_02",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "epilogue_flame_02",
            speaker: .narrator,
            text: "You think about the farmer and his harvest. The first question you were ever asked in this room.\n\nYou think about the burning ships and whose they were.\n\nYou think about Leonidas's face when you finished speaking — whatever you said — and the nod that followed.",
            choices: nil,
            nextNodeID: "epilogue_flame_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "epilogue_flame_03",
            speaker: .narrator,
            text: "You think about Lyra.\n\nYou think about Demetrios — what he did, what he tried to do, what he believed he was protecting.\n\nYou think about the silence, and what you found inside it.",
            choices: nil,
            nextNodeID: "epilogue_flame_04",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "epilogue_flame_04",
            speaker: .narrator,
            text: "The flame does not ask you anything.\n\nIt simply burns.\n\nAnd you understand — sitting here with everything you have carried to this room — that this is the last question Apollo will ever ask you. Or the last question you will ever ask yourself. It is the same question either way.",
            choices: nil,
            nextNodeID: "epilogue_final_choice",
            trigger: nil,
            teaches: nil
        ),

        // THE FINAL CHOICE — wordless, weightless, everything
        DialogueNode (
            id: "epilogue_final_choice",
            speaker: .narrator,
            text: "The flame burns before you.\n\nYou can tend it — lean forward, adjust the wick, feed it what it needs to keep burning through the night.\n\nOr you can let it burn — sit back, fold your hands, let it find its own level in the dark.\n\nThe flame continues either way.\n\nBut you are still here. And you must choose what that means.",
            choices: [
                DialogueChoice (
                    id: "tend_flame",
                    text: "Tend the flame.",
                    requires: nil,
                    leadsTo: "epilogue_ending_resolve",
                    teaches: nil,
                    axisNote: "Active — she chooses to continue"
                ),
                DialogueChoice (
                    id: "let_burn",
                    text: "Let it burn.",
                    requires: nil,
                    leadsTo: "epilogue_ending_resolve",
                    teaches: nil,
                    axisNote: "Passive — she releases control"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // Resolve node — leads to one of four endings based on knowledge axes.
        // NarrativeEngine will need to check KnowledgeState.resolveEnding()
        // and route to the correct ending node.
        // For now this node routes to a branch selector via trigger.
        DialogueNode (
            id: "epilogue_ending_resolve",
            speaker: .narrator,
            text: "The flame holds.",
            choices: nil,
            nextNodeID: "epilogue_ending_branch",
            trigger: nil,
            teaches: nil
        ),

        // Branch selector — routes to the correct ending.
        // This node is a pass-through; SceneView observes currentNode.id
        // and when it equals "epilogue_ending_branch", it calls
        // engine.routeToEnding() which advances to the resolved ending node.
        DialogueNode (
            id: "epilogue_ending_branch",
            speaker: .narrator,
            text: "",
            choices: nil,
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - The Four Endings

    static let endings: [DialogueNode] = [

        // --- THE PROPHET (Faith intact + Integrity intact) ---
        DialogueNode (
            id: "epilogue_ending_prophet_01",
            speaker: .narrator,
            text: "The flame burns steadily.\n\nYou believe the god spoke through you. You believe you told the truth when it cost you something real. You are still here — not because the temple kept you, but because you chose to stay.",
            choices: nil,
            nextNodeID: "epilogue_ending_prophet_02",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "epilogue_ending_prophet_02",
            speaker: .narrator,
            text: "Delphi will change. The temple will find another Oracle, or it will not. The restoration may happen, or it may not. Athens and Thebes will make their own peace with what occurred.\n\nNone of this is your concern anymore.\n\nWhat is your concern — the only thing that ever was — is what you said when it mattered, and whether you meant it.",
            choices: nil,
            nextNodeID: "epilogue_ending_prophet_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "epilogue_ending_prophet_03",
            speaker: .narrator,
            text: "You meant it.\n\nThe flame burns steadily.\n\nYou sit with it a while longer — not because you need to, but because it is beautiful, and you are still capable of noticing that.",
            choices: nil,
            nextNodeID: "epilogue_credits",
            trigger: nil,
            teaches: nil
        ),

        // --- THE MARTYR (Faith intact + Integrity broken) ---
        DialogueNode (
            id: "epilogue_ending_martyr_01",
            speaker: .narrator,
            text: "The flame flickers.\n\nYou believe the god spoke through you. That is the part you cannot put down — the certainty that something larger moved through this room, through you, toward the world.\n\nAnd you compromised it.",
            choices: nil,
            nextNodeID: "epilogue_ending_martyr_02",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "epilogue_ending_martyr_02",
            speaker: .narrator,
            text: "Not from cruelty. From fear, or pragmatism, or the weight of what would be lost. You told yourself the reasons were good enough.\n\nSitting here now, with the flame, you are not sure they were.\n\nYou are not sure they weren't. That is the particular torment of the martyr — not knowing whether the sacrifice was necessary or simply convenient.",
            choices: nil,
            nextNodeID: "epilogue_ending_martyr_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "epilogue_ending_martyr_03",
            speaker: .narrator,
            text: "The flame flickers.\n\nYou do not know if it is the draft from the corridor, or something else.\n\nYou watch it a long time, hoping it will tell you something.\n\nIt does not.",
            choices: nil,
            nextNodeID: "epilogue_credits",
            trigger: nil,
            teaches: nil
        ),

        // --- THE PHILOSOPHER (Faith broken + Integrity intact) ---
        DialogueNode (
            id: "epilogue_ending_philosopher_01",
            speaker: .narrator,
            text: "The flame burns.\n\nYou no longer believe the god spoke through you. You have sat with that conclusion long enough that it has stopped feeling like a wound and started feeling like a room — unfamiliar, but yours.\n\nThe visions were you. The truth in them was you.",
            choices: nil,
            nextNodeID: "epilogue_ending_philosopher_02",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "epilogue_ending_philosopher_02",
            speaker: .narrator,
            text: "You told it anyway. You spoke what you saw, in the face of every reason not to, because truth matters regardless of its origin. Not because Apollo commanded it. Because you decided it.\n\nThat is not a smaller thing than prophecy.\n\nIt may be a larger one.",
            choices: nil,
            nextNodeID: "epilogue_ending_philosopher_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "epilogue_ending_philosopher_03",
            speaker: .narrator,
            text: "The flame burns.\n\nIt does not need to mean anything beyond what it is — fire, warmth, light in a dark room.\n\nYou find, sitting here, that this is enough.\n\nYou find, to your own mild surprise, that you are all right.",
            choices: nil,
            nextNodeID: "epilogue_credits",
            trigger: nil,
            teaches: nil
        ),

        // --- THE HOLLOW (Faith broken + Integrity broken) ---
        DialogueNode (
            id: "epilogue_ending_hollow_01",
            speaker: .narrator,
            text: "The flame goes dark.\n\nYou sit in the adyton in absolute darkness for a moment — the length of a breath, the length of a life — and then you reach forward and relight it from the tinder beside the tripod.\n\nMechanically. The way you have done everything, in the end.",
            choices: nil,
            nextNodeID: "epilogue_ending_hollow_02",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "epilogue_ending_hollow_02",
            speaker: .narrator,
            text: "You do not believe the god spoke through you. You are not sure you ever did, or if you did, you traded it away so gradually you cannot point to the moment it was gone.\n\nYou said what they needed you to say. You found the words. You were very good at it.\n\nYou are still very good at it.",
            choices: nil,
            nextNodeID: "epilogue_ending_hollow_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "epilogue_ending_hollow_03",
            speaker: .narrator,
            text: "The flame burns again. You watch it.\n\nTomorrow there will be more supplicants. More questions. More chances to give people something they can act on.\n\nYou will find the words.\n\nYou always do.\n\nYou sit in the adyton and watch the flame and try to remember the last time you said something you actually believed.\n\nYou cannot.",
            choices: nil,
            nextNodeID: "epilogue_credits",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - Credits Beat

    static let credits: [DialogueNode] = [
        DialogueNode (
            id: "epilogue_credits",
            speaker: .narrator,
            text: "She sees the fire before it is lit.\nShe speaks, and the world decides whether to listen.",
            choices: nil,
            nextNodeID: "epilogue_end",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "epilogue_end",
            speaker: .narrator,
            text: "PYTHIA\n\nDelphi, 480 BC",
            choices: nil,
            nextNodeID: nil,
            trigger: .endGame,
            teaches: nil
        ),
    ]
}
