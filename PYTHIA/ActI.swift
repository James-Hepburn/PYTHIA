// ActI.swift
// PYTHIA
//
// All dialogue nodes for Act I — "The Voice".
// ~20 minutes of play. Covers:
//   · Mara's purification ritual at the Sacred Spring (silent prologue)
//   · First consultation — the harvest farmer (vision mechanic introduced)
//   · Meeting Demetrios as warm mentor
//   · Meeting Lyra
//   · Optional journal entry (backstory)
//   · Nikomedes's arrival observed from a distance
//   · Act I close — the Athenian delegation formally requests audience
//
// Node ID naming convention:
//   act1_[scene]_[beat]
//   Vision return nodes: [sessionID]_return
//
// To add content: add cases to the nodes array.
// The engine will find them automatically by ID.

import SwiftUI

enum ActI {
    static var nodes: [DialogueNode] {
        prologue + harvestVision + meetDemetrios + meetLyra + journal + nikomedosArrival + actClose
    }

    // MARK: - Prologue: The Sacred Spring (no dialogue — narration only)

    static let prologue: [DialogueNode] = [
        DialogueNode (
            id: "act1_prologue_01",
            speaker: .narrator,
            text: "Before dawn. The sanctuary is still.\n\nYou have not slept.",
            choices: nil,
            nextNodeID: "act1_prologue_02",
            trigger: .enterLocation (.sacredSpring),
            teaches: .completedPurificationRitual
        ),

        DialogueNode (
            id: "act1_prologue_02",
            speaker: .narrator,
            text: "The Sacred Spring is cold. The priests say the water carries Apollo's breath up from the earth. You cup it in both hands and drink before you can think about what that means.",
            choices: nil,
            nextNodeID: "act1_prologue_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_prologue_03",
            speaker: .narrator,
            text: "You are twenty-four years old. Three weeks ago you were grinding grain in a village three hours' walk from here.\n\nNow you are the mouth of a god.",
            choices: nil,
            nextNodeID: "act1_prologue_04",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_prologue_04",
            speaker: .narrator,
            text: "The laurel wreath is heavier than it looks.\n\nYou walk toward the temple.",
            choices: nil,
            nextNodeID: "act1_first_supplicant_01",
            trigger: .enterLocation (.adyton),
            teaches: nil
        ),
    ]

    // MARK: - First Vision: The Harvest Farmer

    static let harvestVision: [DialogueNode] = [
        DialogueNode (
            id: "act1_first_supplicant_01",
            speaker: .narrator,
            text: "The first supplicant is a farmer from the valley. He has walked since yesterday. His sandals are worn through at the heel.\n\nHe kneels without being asked.",
            choices: nil,
            nextNodeID: "act1_first_supplicant_02",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_first_supplicant_02",
            speaker: .narrator,
            text: "\"Great Oracle,\" he says. \"My harvest. Will it hold? I have a wife, four children. Last season we lost half to the rot.\"\n\nHis voice doesn't shake. That makes it worse.",
            choices: nil,
            nextNodeID: "act1_first_supplicant_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_first_supplicant_03",
            speaker: .narrator,
            text: "You close your eyes. You breathe. The smoke from the laurel branches fills the chamber.\n\nAnd then — something opens.",
            choices: nil,
            nextNodeID: "act1_harvest_vision_trigger",
            trigger: nil,
            teaches: nil
        ),

        // This node fires the vision session
        DialogueNode (
            id: "act1_harvest_vision_trigger",
            speaker: .narrator,
            text: "The world falls away.",
            choices: nil,
            nextNodeID: nil,
            trigger: .beginVisionSession (
                sessionID: "harvest",
                fragments: ActI.harvestFragments
            ),
            teaches: nil
        ),

        // Return node — engine advances here after vision completes
        DialogueNode (
            id: "harvest_return",
            speaker: .narrator,
            text: "You return. The adyton is as it was. The farmer is still kneeling.\n\nThe fragments of what you saw settle like silt in still water.",
            choices: nil,
            nextNodeID: "act1_harvest_prophecy_choice",
            trigger: nil,
            teaches: .deliveredHarvestProphecy
        ),

        // First real player choice — how to frame the prophecy
        DialogueNode (
            id: "act1_harvest_prophecy_choice",
            speaker: .mara,
            text: "The vision was gentle but not simple. How do you speak it?",
            choices: [
                DialogueChoice (
                    id: "harvest_direct",
                    text: "\"Wait for the third rain before you sow. The earth is not yet ready.\"",
                    requires: nil,
                    leadsTo: "act1_harvest_response_direct",
                    teaches: nil,
                    axisNote: "Direct, practical — no axis impact"
                ),
                DialogueChoice (
                    id: "harvest_oblique",
                    text: "\"Apollo sees your fields. What the water withholds, patience returns.\"",
                    requires: nil,
                    leadsTo: "act1_harvest_response_oblique",
                    teaches: .usedOracularAmbiguityAsShield,
                    axisNote: "Oracular tradition — mild integrity cost"
                ),
                DialogueChoice (
                    id: "harvest_honest",
                    text: "\"I saw grain and I saw waiting. I believe it will hold — but not without care.\"",
                    requires: nil,
                    leadsTo: "act1_harvest_response_honest",
                    teaches: nil,
                    axisNote: "Honest about uncertainty — no axis impact, establishes Mara's voice"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_harvest_response_direct",
            speaker: .narrator,
            text: "The farmer nods slowly, committing your words to memory. He leaves a small clay offering — a grain stalk pressed into terracotta.\n\nFrom the doorway, Demetrios watches.",
            choices: nil,
            nextNodeID: "act1_meet_demetrios_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_harvest_response_oblique",
            speaker: .narrator,
            text: "The farmer bows his head. He seems comforted, though you are not certain he understood. He leaves a small clay offering.\n\nFrom the doorway, Demetrios watches with something like approval.",
            choices: nil,
            nextNodeID: "act1_meet_demetrios_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_harvest_response_honest",
            speaker: .narrator,
            text: "The farmer looks up. This is not the Oracle's voice — it sounds like a person. His eyes are wet.\n\n\"Thank you,\" he says quietly.\n\nFrom the doorway, Demetrios watches. His expression is unreadable.",
            choices: nil,
            nextNodeID: "act1_meet_demetrios_01",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - Meet Demetrios

    static let meetDemetrios: [DialogueNode] = [
        DialogueNode (
            id: "act1_meet_demetrios_01",
            speaker: .narrator,
            text: "He waits until the farmer has gone. Then he crosses the threshold, unhurried, and stands before you.\n\nHe is old in the way stone is old — worn smooth, not diminished.",
            choices: nil,
            nextNodeID: "act1_meet_demetrios_02",
            trigger: .enterLocation (.templeForecourt),
            teaches: .metDemetrios
        ),

        DialogueNode (
            id: "act1_meet_demetrios_02",
            speaker: .demetrios,
            text: "\"You did well. Better than I expected, to speak plainly.\"\n\nHe gestures for you to walk with him.",
            choices: nil,
            nextNodeID: "act1_meet_demetrios_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_meet_demetrios_03",
            speaker: .demetrios,
            text: "\"The god speaks in fragments. He always has. Our task — yours and mine — is not to report what we see, but to translate it into something that can be used.\"\n\nHe pauses at a column.",
            choices: nil,
            nextNodeID: "act1_meet_demetrios_04",
            trigger: nil,
            teaches: .demetriosExplainedPhilosophy
        ),

        DialogueNode (
            id: "act1_meet_demetrios_04",
            speaker: .demetrios,
            text: "\"A king who receives a vision of burning ships and collapses in despair serves no one. A king who receives the same vision and understands it as warning, as instruction, goes home and builds a better fleet. Do you see the difference?\"",
            choices: nil,
            nextNodeID: "act1_demetrios_response",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_demetrios_response",
            speaker: .mara,
            text: "How do you respond?",
            choices: [
                DialogueChoice (
                    id: "demetrios_agree",
                    text: "\"I understand. The truth is only useful if it can be received.\"",
                    requires: nil,
                    leadsTo: "act1_demetrios_agrees",
                    teaches: nil,
                    axisNote: "Reasonable — no axis impact yet"
                ),
                DialogueChoice (
                    id: "demetrios_question",
                    text: "\"Who decides what can be received? The king, or us?\"",
                    requires: nil,
                    leadsTo: "act1_demetrios_questioned",
                    teaches: nil,
                    axisNote: "Early sign of Mara's conscience"
                ),
                DialogueChoice (
                    id: "demetrios_silent",
                    text: "Say nothing. Let him take your silence as agreement.",
                    requires: nil,
                    leadsTo: "act1_demetrios_silence",
                    teaches: nil,
                    axisNote: "Neither agrees nor disagrees"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_demetrios_agrees",
            speaker: .demetrios,
            text: "He nods, satisfied.\n\n\"Good. You will learn.\"\n\nHe seems genuinely pleased. You are not sure whether that comforts you.",
            choices: nil,
            nextNodeID: "act1_meet_lyra_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_demetrios_questioned",
            speaker: .demetrios,
            text: "He looks at you for a long moment.\n\n\"Both,\" he says finally. \"The wise intermediary considers both.\"\n\nHe seems less settled than he was. That is not necessarily a bad sign.",
            choices: nil,
            nextNodeID: "act1_meet_lyra_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_demetrios_silence",
            speaker: .narrator,
            text: "He holds your gaze, then inclines his head slightly.\n\n\"Rest. There will be more tomorrow.\"\n\nYou cannot tell whether he is satisfied.",
            choices: nil,
            nextNodeID: "act1_meet_lyra_01",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - Meet Lyra

    static let meetLyra: [DialogueNode] = [
        DialogueNode (
            id: "act1_meet_lyra_01",
            speaker: .narrator,
            text: "She is waiting outside your quarters. Seventeen, perhaps. She bows before you have a chance to tell her not to.",
            choices: nil,
            nextNodeID: "act1_meet_lyra_02",
            trigger: .enterLocation (.marasQuarters),
            teaches: .metLyra
        ),

        DialogueNode (
            id: "act1_meet_lyra_02",
            speaker: .lyra,
            text: "\"I'm Lyra. I've been assigned to help you prepare for the rituals. I'll fetch water, lay out the laurel, anything you need.\"\n\nShe says this with great seriousness, as if reciting something she practised.",
            choices: nil,
            nextNodeID: "act1_meet_lyra_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_meet_lyra_03",
            speaker: .mara,
            text: "How do you receive her?",
            choices: [
                DialogueChoice (
                    id: "lyra_warm",
                    text: "\"Thank you, Lyra. I'm glad it's you and not someone who already knows how everything is supposed to be done.\"",
                    requires: nil,
                    leadsTo: "act1_lyra_warm_response",
                    teaches: nil,
                    axisNote: "Warmth — Lyra becomes more present"
                ),
                DialogueChoice (
                    id: "lyra_formal",
                    text: "\"Thank you. I'll let you know when I need something.\"",
                    requires: nil,
                    leadsTo: "act1_lyra_formal_response",
                    teaches: nil,
                    axisNote: "Distance — she withdraws slightly"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_lyra_warm_response",
            speaker: .lyra,
            text: "She smiles — quickly, like she caught herself doing something she wasn't supposed to.\n\n\"I've never spoken to the Pythia before. The old one, she never— well. I'm glad you're here.\"",
            choices: nil,
            nextNodeID: "act1_journal_prompt",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_lyra_formal_response",
            speaker: .lyra,
            text: "\"Of course, Pythia.\"\n\nShe bows again and steps back. You have the room to yourself. It is very quiet.",
            choices: nil,
            nextNodeID: "act1_journal_prompt",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - Optional Journal

    static let journal: [DialogueNode] = [
        DialogueNode (
            id: "act1_journal_prompt",
            speaker: .narrator,
            text: "There is a wax tablet on the small table. The previous Pythia's writing has been scraped away, but the impressions of her words still show in the wax if you hold it to the light.",
            choices: [
                DialogueChoice (
                    id: "read_journal",
                    text: "Write something — a memory of home.",
                    requires: nil,
                    leadsTo: "act1_journal_entry",
                    teaches: .readJournalEntry_beforeTemple,
                    axisNote: "Optional backstory"
                ),
                DialogueChoice (
                    id: "skip_journal",
                    text: "Leave it. You are tired.",
                    requires: nil,
                    leadsTo: "act1_nikomedes_transition",
                    teaches: nil,
                    axisNote: "Skip the optional content"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_journal_entry",
            speaker: .mara,
            text: "You write: my mother's hands. The way she would check the grain by pressing her thumb into it. How she never needed a god to tell her when things were ready.\n\nYou stare at what you have written for a long time.",
            choices: nil,
            nextNodeID: "act1_nikomedes_transition",
            trigger: .openJournal,
            teaches: nil
        ),
    ]

    // MARK: - Nikomedes Arrives

    static let nikomedosArrival: [DialogueNode] = [
        DialogueNode (
            id: "act1_nikomedes_transition",
            speaker: .narrator,
            text: "Three days pass.\n\nThe routine settles around you like a garment you have not yet grown used to wearing. You begin to recognise faces in the forecourt. You begin to hear things.",
            choices: nil,
            nextNodeID: "act1_nikomedes_01",
            trigger: .enterLocation (.templeForecourt),
            teaches: nil
        ),

        DialogueNode (
            id: "act1_nikomedes_01",
            speaker: .narrator,
            text: "The Athenian delegation arrives at midday — twelve men, well-armed, with the dust of a long road on them. Their leader moves through the forecourt as if he already owns it.",
            choices: nil,
            nextNodeID: "act1_nikomedes_02",
            trigger: nil,
            teaches: .observedNikomedosArrival
        ),

        DialogueNode (
            id: "act1_nikomedes_02",
            speaker: .narrator,
            text: "You hear him before you see him clearly. Sharp-voiced. Asking a temple servant which city-states have already been received.\n\nThe servant hedges. The Athenian does not look satisfied.",
            choices: nil,
            nextNodeID: "act1_nikomedes_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_nikomedes_03",
            speaker: .narrator,
            text: "You catch his eye for a moment as you cross the forecourt.\n\nHe notices you. He notes you.\n\nThat is not the same thing as being seen.",
            choices: nil,
            nextNodeID: "act1_close_01",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - Act I Close

    static let actClose: [DialogueNode] = [
        DialogueNode (
            id: "act1_close_01",
            speaker: .demetrios,
            text: "Demetrios finds you that evening.\n\n\"The Athenians have formally requested an audience. They want the Oracle's counsel on the Persian fleet. I need you to understand something before that session.\"",
            choices: nil,
            nextNodeID: "act1_close_02",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_close_02",
            speaker: .demetrios,
            text: "\"Athens funds a third of the temple's restoration. Thebes another quarter. What the Oracle says to Athens will be heard by Thebes within a week. What the Oracle says to Thebes will reach Sparta before the month is out.\"\n\nHe lets that land.",
            choices: nil,
            nextNodeID: "act1_close_03",
            trigger: nil,
            teaches: .knowsDelphineFundingArrangement
        ),

        DialogueNode (
            id: "act1_close_03",
            speaker: .demetrios,
            text: "\"I am not asking you to lie. I am asking you to understand the weight of every word before you speak it.\"\n\nHe goes.",
            choices: nil,
            nextNodeID: "act1_close_04",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act1_close_04",
            speaker: .narrator,
            text: "You stand in the forecourt alone.\n\nThe Persian army is somewhere to the north, growing larger by the day.\n\nThe Athenians are waiting.\n\nThe god, if he is here at all, is silent.",
            choices: nil,
            nextNodeID: "act1_close_end",
            trigger: nil,
            teaches: nil
        ),

        // Act I end — this is where Act II nodes will pick up
        DialogueNode (
            id: "act1_close_end",
            speaker: .narrator,
            text: "— ACT II —\n\nTHE DELEGATIONS",
            choices: nil,
            nextNodeID: nil,    // Will link to act2_open_01 when Act II is built
            trigger: .actTransition (toAct: 2),
            teaches: nil
        ),
    ]

    // MARK: - Vision Fragments: The Harvest

    /// The six fragments shown during the first vision session.
    /// Low stakes, easy to interpret — this is the tutorial vision.
    static let harvestFragments: [Fragment] = [
        Fragment (
            id: "harvest_grain",
            type: .image (symbolName: "leaf.fill"),
            significance: "abundance — or the memory of it"
        ),
        Fragment (
            id: "harvest_rain",
            type: .sensation (text: "cold water\non warm stone"),
            significance: "something arriving from outside — beyond control"
        ),
        Fragment (
            id: "harvest_wait",
            type: .word (text: "WAIT"),
            significance: "patience, or warning — the same gesture, different hands"
        ),
        Fragment (
            id: "harvest_sun",
            type: .colour (hue: Color (red: 0.85, green: 0.65, blue: 0.20)),
            significance: "the colour of a season that has not yet turned"
        ),
        Fragment (
            id: "harvest_children",
            type: .image (symbolName: "figure.2.and.child.holdinghands"),
            significance: "what the question is really about"
        ),
        Fragment (
            id: "harvest_silence",
            type: .sensation (text: "the stillness\nbefore a door opens"),
            significance: "threshold — not yet, but soon"
        ),
    ]
}
