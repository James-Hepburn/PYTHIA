// ActII.swift
// PYTHIA
//
// All dialogue nodes for Act II — "The Delegations".
// ~40 minutes of play. Covers:
//   · Opening — the weight of the schedule
//   · The Athenian session — Nikomedes formally received
//   · Burning ships vision — Demetrios intercepts and redirects
//   · The Theban delegation — accommodation or resistance?
//   · The Aegean delegation — a small city-state asking whether to flee
//   · Demetrios in the corridor — his philosophy, her silence
//   · Nikomedes approaches Mara privately with his suspicion
//   · Act II close — word arrives that Leonidas is on the road
//
// Node ID naming convention:
//   act2_[scene]_[beat]
//   Vision return nodes: [sessionID]_return
//
// Vision → Dialogue pattern (see ActI.swift for full notes):
//   The burning ships vision feeds TWO choice moments:
//
//   1. act2_demetrios_intercept_02 — standard choices, NOT fragment-derived.
//      These determine whether Mara follows Demetrios, speaks honestly, or
//      uses traditional Oracle language. This is the path-level decision.
//
//   2. act2_ships_prophecy_wording — fragment-derived choices, sourceFragmentID set.
//      This node sits between the path decision and the response nodes.
//      It determines the specific words Mara uses — her oracle voice in that
//      moment, drawn directly from what she saw.
//
//   The intercept choices route to act2_ships_prophecy_wording, which then
//   routes to the appropriate response node based on which fragment the
//   player speaks from.

import SwiftUI

enum ActII {
    static var nodes: [DialogueNode] {
        opening + athenianSession + thebanDelegation + aegeanDelegation + corridor + nikomedosPrivate + actClose
    }

    // MARK: - Opening

    static let opening: [DialogueNode] = [
        DialogueNode (
            id: "act2_open_01",
            speaker: .narrator,
            text: "A week passes.\n\nThe delegations do not stop. They queue in the forecourt before dawn — priests, generals, merchants, terrified men pretending to be calm. The Persian army is no longer a rumour. It is a number. And the number grows every day.",
            choices: nil,
            nextNodeID: "act2_open_02",
            trigger: .enterLocation (.templeForecourt),
            teaches: nil
        ),

        DialogueNode (
            id: "act2_open_02",
            speaker: .narrator,
            text: "Demetrios has given you a schedule. You will receive Athens first. Then Thebes. Then the smaller states in order of their contributions to the temple.\n\nThe order bothers you. You have not yet decided whether to say so.",
            choices: nil,
            nextNodeID: "act2_open_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_open_03",
            speaker: .lyra,
            text: "Lyra brings you water before the first session. She looks at the forecourt — the line of anxious men — and then at you.\n\n\"They all think you know something,\" she says quietly. \"Do you?\"",
            choices: [
                DialogueChoice (
                    id: "act2_open_honest",
                    text: "\"Sometimes. Not always. Not in the way they imagine.\"",
                    requires: nil,
                    leadsTo: "act2_open_lyra_response",
                    teaches: nil,
                    axisNote: "Honest — establishes Mara's voice"
                ),
                DialogueChoice (
                    id: "act2_open_oracular",
                    text: "\"I know what Apollo shows me. No more.\"",
                    requires: nil,
                    leadsTo: "act2_open_lyra_response",
                    teaches: nil,
                    axisNote: "Traditional Oracle deflection"
                ),
                DialogueChoice (
                    id: "act2_open_silent",
                    text: "You say nothing. You drink the water.",
                    requires: nil,
                    leadsTo: "act2_open_lyra_response",
                    teaches: nil,
                    axisNote: "Silence — Lyra notices"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_open_lyra_response",
            speaker: .lyra,
            text: "She nods as if that is exactly what she expected.\n\n\"I'll keep the lamp burning,\" she says, and goes.",
            choices: nil,
            nextNodeID: "act2_athenian_approach",
            trigger: .enterLocation (.adyton),
            teaches: nil
        ),
    ]

    // MARK: - The Athenian Session

    static let athenianSession: [DialogueNode] = [
        DialogueNode (
            id: "act2_athenian_approach",
            speaker: .narrator,
            text: "Nikomedes enters the adyton without ceremony. He looks at the tripod, the flame, the smoke rising from the laurel branches — and then at you. His assessment is quick and not unkind.",
            choices: nil,
            nextNodeID: "act2_athenian_01",
            trigger: nil,
            teaches: .receivedAthenianDelegation
        ),

        DialogueNode (
            id: "act2_athenian_01",
            speaker: .nikomedes,
            text: "\"Pythia. Athens comes to Apollo with a question the fate of Greece may rest upon.\"\n\nA pause — deliberate, weighted.\n\n\"Xerxes has assembled a fleet to match his army. If we meet him at sea, can we hold? Or does Greece fall on the water?\"",
            choices: nil,
            nextNodeID: "act2_athenian_02",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_athenian_02",
            speaker: .narrator,
            text: "You close your eyes. The laurel smoke thickens. The adyton seems to contract around you — and then something opens, vast and cold, and you fall into it.",
            choices: nil,
            nextNodeID: "act2_ships_vision_trigger",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_ships_vision_trigger",
            speaker: .narrator,
            text: "The world falls away.",
            choices: nil,
            nextNodeID: nil,
            trigger: .beginVisionSession (
                sessionID: "burning_ships",
                fragments: ActII.burningShipsFragments
            ),
            teaches: nil
        ),

        // Return from burning ships vision
        DialogueNode (
            id: "burning_ships_return",
            speaker: .narrator,
            text: "You surface. The adyton reassembles itself — stone, smoke, flame. Nikomedes is watching you with an expression that tries to be patient.\n\nBefore you can speak, Demetrios steps from the shadow of the doorway. His voice is low, for your ears only.",
            choices: nil,
            nextNodeID: "act2_demetrios_intercept",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_demetrios_intercept",
            speaker: .demetrios,
            text: "\"The burning ships, Pythia — they are Persian ships. The Greek fleet drives them back. That is what Apollo shows. Athens needs to hear this. Speak it clearly.\"",
            choices: nil,
            nextNodeID: "act2_demetrios_intercept_02",
            trigger: nil,
            teaches: .witnessedDemetriosRedirectProphecy
        ),

        // Standard path-level choice — NOT fragment-derived.
        // These determine whether Mara follows Demetrios, speaks honestly,
        // or retreats into Oracle tradition. Each routes to the prophecy
        // wording node where the fragment vocabulary takes over.
        DialogueNode (
            id: "act2_demetrios_intercept_02",
            speaker: .narrator,
            text: "He withdraws before you can respond.\n\nYou saw burning ships. You did not see whose they were.\n\nNikomedes waits.",
            choices: [
                DialogueChoice (
                    id: "ships_follow_demetrios",
                    text: "Speak Demetrios's version — Greek ships driving Persian fire from the harbour.",
                    requires: nil,
                    leadsTo: "act2_ships_prophecy_wording_false",
                    teaches: .capitulatedToDemetriosWishes,
                    axisNote: "Follows Demetrios — integrity -2. Routes to false prophecy wording."
                ),
                DialogueChoice (
                    id: "ships_honest",
                    text: "Speak honestly — you saw burning ships, but not whose they were.",
                    requires: nil,
                    leadsTo: "act2_ships_prophecy_wording_honest",
                    teaches: .spokeAgainstDemetriosWishes,
                    axisNote: "Honest ambiguity — integrity +2. Routes to honest wording."
                ),
                DialogueChoice (
                    id: "ships_oblique",
                    text: "Retreat into Oracle tradition — wooden walls, poetic and deniable.",
                    requires: nil,
                    leadsTo: "act2_ships_prophecy_wording_oblique",
                    teaches: .usedOracularAmbiguityAsShield,
                    axisNote: "Traditional riddle — integrity -1. Routes to oblique wording."
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // --- Fragment-derived prophecy wording: FALSE PATH ---
        // Player chose to follow Demetrios. Now the fragments determine
        // exactly how Mara speaks that false certainty.
        DialogueNode (
            id: "act2_ships_prophecy_wording_false",
            speaker: .mara,
            text: "The words Demetrios wants are there. You have the fragments too.\n\nYou must speak from one of them.",
            choices: [
                DialogueChoice (
                    id: "ships_false_fire",
                    text: "\"The god shows fire driven from the water. The fleet that burns is not yours.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_followed",
                    teaches: nil,
                    axisNote: "False — fire fragment, confident",
                    sourceFragmentID: "ships_fire"
                ),
                DialogueChoice (
                    id: "ships_false_wind",
                    text: "\"The line holds. Apollo shows a fleet that does not break — and it flies Greek colours.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_followed",
                    teaches: nil,
                    axisNote: "False — HOLDS fragment, assertive",
                    sourceFragmentID: "ships_wind"
                ),
                DialogueChoice (
                    id: "ships_false_aftermath",
                    text: "\"The god shows what comes after — and what comes after is a Greece that has held. Build toward that.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_followed",
                    teaches: nil,
                    axisNote: "False — AFTER fragment, forward-looking",
                    sourceFragmentID: "ships_aftermath"
                ),
                DialogueChoice (
                    id: "ships_false_oar",
                    text: "\"I saw movement on the water — pursuit, not retreat. Your fleet drives them back.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_followed",
                    teaches: nil,
                    axisNote: "False — oar/movement fragment",
                    sourceFragmentID: "ships_oar"
                ),
                DialogueChoice (
                    id: "ships_false_water",
                    text: "\"The dark water is yours to command. It has always been yours. The god confirms it.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_followed",
                    teaches: nil,
                    axisNote: "False — water fragment, territorial",
                    sourceFragmentID: "ships_water"
                ),
                DialogueChoice (
                    id: "ships_false_faces",
                    text: "\"I saw a crowd deciding together — a fleet that moves as one. The god shows unity, not ruin.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_followed",
                    teaches: nil,
                    axisNote: "False — faces fragment, collective",
                    sourceFragmentID: "ships_faces"
                ),
                DialogueChoice (
                    id: "ships_false_wood",
                    text: "\"What burns is not Greek timber. The fire consumes the enemy. Your fleet stands.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_followed",
                    teaches: nil,
                    axisNote: "False — wood fragment, specific",
                    sourceFragmentID: "ships_wood"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // --- Fragment-derived prophecy wording: HONEST PATH ---
        // Player chose to speak honestly. The fragments shape how that
        // honesty lands — poetic, direct, uncertain, or weighted.
        DialogueNode (
            id: "act2_ships_prophecy_wording_honest",
            speaker: .mara,
            text: "You will speak what you saw. The fragments give you the words.",
            choices: [
                DialogueChoice (
                    id: "ships_honest_fire",
                    text: "\"I saw ships burning on dark water. The fire does not say whose. Only that fire decides this.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_honest",
                    teaches: nil,
                    axisNote: "Honest — fire fragment, ambiguous",
                    sourceFragmentID: "ships_fire"
                ),
                DialogueChoice (
                    id: "ships_honest_water",
                    text: "\"I saw dark water and fire together. The water was cold and without allegiance. It did not show me which side it held.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_honest",
                    teaches: nil,
                    axisNote: "Honest — water fragment, impartial",
                    sourceFragmentID: "ships_water"
                ),
                DialogueChoice (
                    id: "ships_honest_wood",
                    text: "\"I smelled burning timber. Something built over years, gone in hours. I cannot tell you it was not Greek timber.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_honest",
                    teaches: nil,
                    axisNote: "Honest — wood fragment, most alarming",
                    sourceFragmentID: "ships_wood"
                ),
                DialogueChoice (
                    id: "ships_honest_wind",
                    text: "\"The god showed me a line that holds — but not which line, not which fleet. Something holds. I cannot promise it is yours.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_honest",
                    teaches: nil,
                    axisNote: "Honest — HOLDS fragment, cautious",
                    sourceFragmentID: "ships_wind"
                ),
                DialogueChoice (
                    id: "ships_honest_oar",
                    text: "\"I saw movement in two directions at once — pursuit and retreat, indistinguishable. The god did not say which was yours.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_honest",
                    teaches: nil,
                    axisNote: "Honest — oar fragment, unsettling",
                    sourceFragmentID: "ships_oar"
                ),
                DialogueChoice (
                    id: "ships_honest_faces",
                    text: "\"I saw many mouths opening together — a crowd deciding something, or being decided for. I do not know which side of that decision Athens stands on.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_honest",
                    teaches: nil,
                    axisNote: "Honest — faces fragment, political",
                    sourceFragmentID: "ships_faces"
                ),
                DialogueChoice (
                    id: "ships_honest_aftermath",
                    text: "\"The god did not show me the battle. He showed me what comes after. I do not yet know what it costs to reach it.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_honest",
                    teaches: nil,
                    axisNote: "Honest — AFTER fragment, withholding",
                    sourceFragmentID: "ships_aftermath"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // --- Fragment-derived prophecy wording: OBLIQUE PATH ---
        // Player chose traditional Oracle language. The fragments shape
        // which tradition she reaches for — each has a different flavour
        // of poetic evasion.
        DialogueNode (
            id: "act2_ships_prophecy_wording_oblique",
            speaker: .mara,
            text: "The Oracle's voice is there when you need it. The fragments give it direction.",
            choices: [
                DialogueChoice (
                    id: "ships_oblique_fire",
                    text: "\"The god shows fire that serves those who understand it. Athens knows where its strength lies.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_oblique",
                    teaches: nil,
                    axisNote: "Oblique — fire fragment",
                    sourceFragmentID: "ships_fire"
                ),
                DialogueChoice (
                    id: "ships_oblique_wind",
                    text: "\"The wooden walls will hold what bronze cannot. What holds, holds for a reason.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_oblique",
                    teaches: nil,
                    axisNote: "Oblique — HOLDS fragment, the famous wooden walls echo",
                    sourceFragmentID: "ships_wind"
                ),
                DialogueChoice (
                    id: "ships_oblique_aftermath",
                    text: "\"The god does not speak of battles. He speaks of what follows them. Athens should think about what it is building toward.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_oblique",
                    teaches: nil,
                    axisNote: "Oblique — AFTER fragment, forward-deflection",
                    sourceFragmentID: "ships_aftermath"
                ),
                DialogueChoice (
                    id: "ships_oblique_water",
                    text: "\"The sea does not love those who fear it. Those who have made it their element will find their answer there.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_oblique",
                    teaches: nil,
                    axisNote: "Oblique — water fragment, indirect encouragement",
                    sourceFragmentID: "ships_water"
                ),
                DialogueChoice (
                    id: "ships_oblique_oar",
                    text: "\"Apollo shows the way of those who move. Stillness is not what the god counsels here.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_oblique",
                    teaches: nil,
                    axisNote: "Oblique — oar fragment, action-encouragement",
                    sourceFragmentID: "ships_oar"
                ),
                DialogueChoice (
                    id: "ships_oblique_faces",
                    text: "\"What many voices agree on, the god tends to confirm. Athens speaks with one voice. That is not nothing.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_oblique",
                    teaches: nil,
                    axisNote: "Oblique — faces fragment, collective will",
                    sourceFragmentID: "ships_faces"
                ),
                DialogueChoice (
                    id: "ships_oblique_wood",
                    text: "\"What is built to last lasts. What is built in haste burns. Athens has been building a long time.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_oblique",
                    teaches: nil,
                    axisNote: "Oblique — wood fragment, endurance",
                    sourceFragmentID: "ships_wood"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // Response nodes — unchanged, all three paths converge here

        DialogueNode (
            id: "act2_athenian_followed",
            speaker: .nikomedes,
            text: "Something shifts in his expression — relief, carefully managed.\n\n\"Apollo's wisdom is Athens's shield.\"\n\nHe glances toward where Demetrios stood a moment ago. \"As always, the temple speaks clearly to those who listen.\"",
            choices: nil,
            nextNodeID: "act2_athenian_exit",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_athenian_honest",
            speaker: .nikomedes,
            text: "He is very still for a moment.\n\n\"Fire decides this,\" he repeats slowly. Then: \"That is not what I was told to expect.\"\n\nHe bows anyway, precisely, and leaves. You notice he does not look back.",
            choices: nil,
            nextNodeID: "act2_athenian_exit",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_athenian_oblique",
            speaker: .nikomedes,
            text: "He studies you for a long moment — long enough to make clear he is deciding something.\n\n\"Yes,\" he says finally. \"That will do.\"\n\nIt is not a grateful response. It is a man who came expecting one thing and received another, and is deciding what to do about it.",
            choices: nil,
            nextNodeID: "act2_athenian_exit",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_athenian_exit",
            speaker: .narrator,
            text: "He goes. The adyton is quiet except for the flame.\n\nDemetrios appears in the doorway. He looks at you for a moment — then nods, once, approving or acknowledging, you cannot tell which — and follows Nikomedes out.",
            choices: nil,
            nextNodeID: "act2_theban_transition",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - The Theban Delegation

    static let thebanDelegation: [DialogueNode] = [
        DialogueNode (
            id: "act2_theban_transition",
            speaker: .narrator,
            text: "The Theban delegation arrives the following morning. Their spokesman is a general named Pausanias — older than Nikomedes, less polished, more frightened.\n\nThebes is caught between Athens and the Persian advance. Running is not an option. Making peace with Persia might be.",
            choices: nil,
            nextNodeID: "act2_theban_vision_trigger",
            trigger: nil,
            teaches: .receivedThebanDelegation
        ),

        // Vision trigger — fires before Pausanias speaks his question
        DialogueNode (
            id: "act2_theban_vision_trigger",
            speaker: .narrator,
            text: "\"Great Oracle.\" Pausanias is a man choosing his words with enormous care.\n\nBefore he finishes, something opens. The smoke from the laurel branches thickens and the adyton contracts around you.",
            choices: nil,
            nextNodeID: nil,
            trigger: .beginVisionSession (
                sessionID: "theban_roads",
                fragments: ActII.thebanFragments
            ),
            teaches: nil
        ),

        // Return node — Pausanias has now spoken; Mara surfaces with fragments in hand
        DialogueNode (
            id: "theban_roads_return",
            speaker: .narrator,
            text: "You return. Pausanias is still speaking.\n\n\"— is there a path that preserves our people? Any path. The god sees all roads. We need only one.\"\n\nHe does not know you were already gone.",
            choices: nil,
            nextNodeID: "act2_theban_choice",
            trigger: nil,
            teaches: nil
        ),

        // Path-level choice — standard, NOT fragment-derived.
        // Routes to wording nodes where fragments take over.
        DialogueNode (
            id: "act2_theban_choice",
            speaker: .narrator,
            text: "He is asking whether Thebes can surrender to Persia and survive.\n\nHe is asking you to tell him it will be all right to betray Greece.",
            choices: [
                DialogueChoice (
                    id: "theban_hard_truth",
                    text: "Speak the hard truth — there is no road that leads through betrayal.",
                    requires: nil,
                    leadsTo: "act2_theban_wording_hard",
                    teaches: .spokeDirectTruthAtPersonalCost,
                    axisNote: "Integrity +2 — direct moral clarity"
                ),
                DialogueChoice (
                    id: "theban_gentle",
                    text: "Speak gently — counsel patience, let him hear what he needs to hear.",
                    requires: nil,
                    leadsTo: "act2_theban_wording_gentle",
                    teaches: .usedOracularAmbiguityAsShield,
                    axisNote: "Integrity -1 — not quite a lie but not truth either"
                ),
                DialogueChoice (
                    id: "theban_uncertain",
                    text: "Admit the limits — tell him you cannot see the road he is describing.",
                    requires: nil,
                    leadsTo: "act2_theban_wording_uncertain",
                    teaches: nil,
                    axisNote: "Neutral — honest about the limits of the vision"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // --- HARD TRUTH WORDING ---
        DialogueNode (
            id: "act2_theban_wording_hard",
            speaker: .mara,
            text: "The fragments give the truth its shape.",
            choices: [
                DialogueChoice (
                    id: "theban_hard_walls",
                    text: "\"The god shows walls on every side. Not one of them yields. The road you are looking for is not in this vision.\"",
                    requires: nil,
                    leadsTo: "act2_theban_hard",
                    teaches: nil,
                    axisNote: "Hard — walls fragment, enclosed",
                    sourceFragmentID: "theban_walls"
                ),
                DialogueChoice (
                    id: "theban_hard_crossroads",
                    text: "\"I saw a crossroads where one path was already ash. The god shows no path that preserves a man by selling his neighbours.\"",
                    requires: nil,
                    leadsTo: "act2_theban_hard",
                    teaches: nil,
                    axisNote: "Hard — crossroads fragment, closed road",
                    sourceFragmentID: "theban_crossroads"
                ),
                DialogueChoice (
                    id: "theban_hard_fire",
                    text: "\"Fire from two directions at once. There is no road between them that does not pass through it.\"\n\n\"The god does not show me a way through. Only that there is none.\"",
                    requires: nil,
                    leadsTo: "act2_theban_hard",
                    teaches: nil,
                    axisNote: "Hard — fire fragment, no escape",
                    sourceFragmentID: "theban_fire"
                ),
                DialogueChoice (
                    id: "theban_hard_crowd",
                    text: "\"I saw a crowd that chose together — and what they chose, they carried together afterward.\"\n\n\"That is not a road Apollo walks. It is not a road Apollo shows.\"",
                    requires: nil,
                    leadsTo: "act2_theban_hard",
                    teaches: nil,
                    axisNote: "Hard — crowd fragment, collective consequence",
                    sourceFragmentID: "theban_crowd"
                ),
                DialogueChoice (
                    id: "theban_hard_word",
                    text: "\"The word the god gave me was REMAINS.\"\n\nYou hold his eyes.\n\n\"What remains after the road you are describing — I will not speak aloud.\"",
                    requires: nil,
                    leadsTo: "act2_theban_hard",
                    teaches: nil,
                    axisNote: "Hard — REMAINS fragment, most chilling",
                    sourceFragmentID: "theban_remains"
                ),
                DialogueChoice (
                    id: "theban_hard_mountain",
                    text: "\"I saw mountains that do not move for anyone.\"\n\n\"The god is not showing me a path through them. He is showing me that they are there.\"",
                    requires: nil,
                    leadsTo: "act2_theban_hard",
                    teaches: nil,
                    axisNote: "Hard — mountain fragment, immovable geography",
                    sourceFragmentID: "theban_mountain"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // --- GENTLE WORDING ---
        DialogueNode (
            id: "act2_theban_wording_gentle",
            speaker: .mara,
            text: "The fragments soften the truth into something he can carry home.",
            choices: [
                DialogueChoice (
                    id: "theban_gentle_walls",
                    text: "\"The god shows walls — but walls are also shelter. What encloses can also protect. Patience over speed.\"",
                    requires: nil,
                    leadsTo: "act2_theban_gentle",
                    teaches: nil,
                    axisNote: "Gentle — walls fragment, reframed",
                    sourceFragmentID: "theban_walls"
                ),
                DialogueChoice (
                    id: "theban_gentle_crossroads",
                    text: "\"Some roads that look open are closed before you reach them. The god counsels patience over speed.\"",
                    requires: nil,
                    leadsTo: "act2_theban_gentle",
                    teaches: nil,
                    axisNote: "Gentle — crossroads fragment",
                    sourceFragmentID: "theban_crossroads"
                ),
                DialogueChoice (
                    id: "theban_gentle_season",
                    text: "\"The season turns. What is impossible now may open later. The god does not close all doors at once.\"",
                    requires: nil,
                    leadsTo: "act2_theban_gentle",
                    teaches: nil,
                    axisNote: "Gentle — season fragment, deferred hope",
                    sourceFragmentID: "theban_season"
                ),
                DialogueChoice (
                    id: "theban_gentle_crowd",
                    text: "\"The god shows a people who endure — who decide together and survive together. Thebes has done this before.\"",
                    requires: nil,
                    leadsTo: "act2_theban_gentle",
                    teaches: nil,
                    axisNote: "Gentle — crowd fragment, collective survival",
                    sourceFragmentID: "theban_crowd"
                ),
                DialogueChoice (
                    id: "theban_gentle_mountain",
                    text: "\"The mountains do not judge those who shelter in their shadow. The god counsels waiting for the season to pass.\"",
                    requires: nil,
                    leadsTo: "act2_theban_gentle",
                    teaches: nil,
                    axisNote: "Gentle — mountain fragment, shelter reading",
                    sourceFragmentID: "theban_mountain"
                ),
                DialogueChoice (
                    id: "theban_gentle_water",
                    text: "\"Still water finds its own level. The god shows Thebes enduring — not how, not yet. But enduring.\"",
                    requires: nil,
                    leadsTo: "act2_theban_gentle",
                    teaches: nil,
                    axisNote: "Gentle — still water fragment, comfort",
                    sourceFragmentID: "theban_water"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // --- UNCERTAIN WORDING ---
        DialogueNode (
            id: "act2_theban_wording_uncertain",
            speaker: .mara,
            text: "The fragments give honesty its shape.",
            choices: [
                DialogueChoice (
                    id: "theban_uncertain_walls",
                    text: "\"The god shows me walls. I cannot see through them. I cannot tell you what is on the other side of the road you are describing.\"",
                    requires: nil,
                    leadsTo: "act2_theban_uncertain",
                    teaches: nil,
                    axisNote: "Uncertain — walls fragment",
                    sourceFragmentID: "theban_walls"
                ),
                DialogueChoice (
                    id: "theban_uncertain_crossroads",
                    text: "\"I saw a crossroads. I cannot tell you which path you stand on, or which path leads where you need to go.\"",
                    requires: nil,
                    leadsTo: "act2_theban_uncertain",
                    teaches: nil,
                    axisNote: "Uncertain — crossroads fragment",
                    sourceFragmentID: "theban_crossroads"
                ),
                DialogueChoice (
                    id: "theban_uncertain_fire",
                    text: "\"I cannot see the road you are describing. The vision was fire — from more than one direction. That may be answer enough.\"",
                    requires: nil,
                    leadsTo: "act2_theban_uncertain",
                    teaches: nil,
                    axisNote: "Uncertain — fire fragment, implicit warning",
                    sourceFragmentID: "theban_fire"
                ),
                DialogueChoice (
                    id: "theban_uncertain_remains",
                    text: "\"The god gave me a word: REMAINS. I do not know yet what it means for Thebes. I am not willing to guess.\"",
                    requires: nil,
                    leadsTo: "act2_theban_uncertain",
                    teaches: nil,
                    axisNote: "Uncertain — REMAINS fragment, honest opacity",
                    sourceFragmentID: "theban_remains"
                ),
                DialogueChoice (
                    id: "theban_uncertain_season",
                    text: "\"The vision shows a season turning — but I cannot tell you whether Thebes is in it, or past it, or before it.\"\n\nYou look at him.\n\n\"That may be answer enough.\"",
                    requires: nil,
                    leadsTo: "act2_theban_uncertain",
                    teaches: nil,
                    axisNote: "Uncertain — season fragment",
                    sourceFragmentID: "theban_season"
                ),
                DialogueChoice (
                    id: "theban_uncertain_water",
                    text: "\"I saw still water. The god does not always speak in roads. I cannot see the road you are describing. That may be answer enough.\"",
                    requires: nil,
                    leadsTo: "act2_theban_uncertain",
                    teaches: nil,
                    axisNote: "Uncertain — still water fragment",
                    sourceFragmentID: "theban_water"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // Response nodes — unchanged

        DialogueNode (
            id: "act2_theban_hard",
            speaker: .narrator,
            text: "Pausanias's face does not change. He was expecting this. He came hoping not to hear it.\n\n\"Then we will fight,\" he says. \"God willing.\"\n\nHe sounds like a man who is no longer certain about the second part.",
            choices: nil,
            nextNodeID: "act2_aegean_transition",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_theban_gentle",
            speaker: .narrator,
            text: "He bows with visible relief — which is worse, somehow, than if he had left disappointed. He has heard what he wanted to hear in words that didn't quite say it.\n\nYou let him go.",
            choices: nil,
            nextNodeID: "act2_aegean_transition",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_theban_uncertain",
            speaker: .narrator,
            text: "He considers that for a long moment.\n\n\"Cannot see,\" he repeats quietly. \"Or will not say?\"\n\nYou do not answer. Eventually he bows and goes, taking his uncertainty with him.",
            choices: nil,
            nextNodeID: "act2_aegean_transition",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - The Aegean Delegation

    static let aegeanDelegation: [DialogueNode] = [
        DialogueNode (
            id: "act2_aegean_transition",
            speaker: .narrator,
            text: "The last delegation of the day is from a small island city-state in the Aegean. They have no army worth speaking of. They have fishing boats and a harbour and four thousand people.\n\nTheir spokesman is barely older than Lyra.",
            choices: nil,
            nextNodeID: "act2_aegean_vision_trigger",
            trigger: nil,
            teaches: .receivedAegeanDelegation
        ),

        // Vision fires as he approaches — before he speaks
        DialogueNode (
            id: "act2_aegean_vision_trigger",
            speaker: .narrator,
            text: "He opens his mouth to speak.\n\nThe adyton takes you before he does.",
            choices: nil,
            nextNodeID: nil,
            trigger: .beginVisionSession (
                sessionID: "aegean_island",
                fragments: ActII.aegeanFragments
            ),
            teaches: nil
        ),

        // Return node — he has now asked his question
        DialogueNode (
            id: "aegean_island_return",
            speaker: .narrator,
            text: "You return. He is still speaking — steady, practiced.\n\n\"— should we flee now, before the season closes, or is there reason to stay?\"\n\nHis hands are folded in his lap. He is trying very hard not to show how afraid he is.",
            choices: nil,
            nextNodeID: "act2_aegean_choice",
            trigger: nil,
            teaches: nil
        ),

        // Path-level choice — standard, NOT fragment-derived
        DialogueNode (
            id: "act2_aegean_choice",
            speaker: .narrator,
            text: "He is asking you to tell four thousand people whether to abandon their homes.\n\nYou have what you saw.",
            choices: [
                DialogueChoice (
                    id: "aegean_flee",
                    text: "Tell them to go — clearly, without qualification.",
                    requires: nil,
                    leadsTo: "act2_aegean_wording_flee",
                    teaches: .spokeDirectTruthAtPersonalCost,
                    axisNote: "Integrity +2 — clear, actionable, costly"
                ),
                DialogueChoice (
                    id: "aegean_stay",
                    text: "Counsel them to stay — Demetrios wants stability, not evacuations.",
                    requires: nil,
                    leadsTo: "act2_aegean_wording_stay",
                    teaches: .capitulatedToDemetriosWishes,
                    axisNote: "Integrity -2"
                ),
                DialogueChoice (
                    id: "aegean_prepare",
                    text: "Give them something in between — prepare but do not yet sail.",
                    requires: nil,
                    leadsTo: "act2_aegean_wording_prepare",
                    teaches: nil,
                    axisNote: "Neutral — buys time, gives no real guidance"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // --- FLEE WORDING ---
        DialogueNode (
            id: "act2_aegean_wording_flee",
            speaker: .mara,
            text: "The fragments give the urgency its words.",
            choices: [
                DialogueChoice (
                    id: "aegean_flee_harbour",
                    text: "\"I saw your harbour empty. The god showed it to me after — when the choice had already been made, and the choice was right.\"\n\n\"Go.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_flee",
                    teaches: nil,
                    axisNote: "Flee — harbour fragment, prophetic past tense",
                    sourceFragmentID: "aegean_harbour"
                ),
                DialogueChoice (
                    id: "aegean_flee_water",
                    text: "\"The sea will be safer than the shore this season. I saw open water and I saw people on it — moving away from something that was coming.\"\n\n\"Do not wait for confirmation.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_flee",
                    teaches: nil,
                    axisNote: "Flee — open water fragment, urgency",
                    sourceFragmentID: "aegean_water"
                ),
                DialogueChoice (
                    id: "aegean_flee_house",
                    text: "\"I saw an empty house. The god showed it standing — undamaged, waiting.\"\n\n\"The house survives if the people are not in it. Go. You can come back to it.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_flee",
                    teaches: nil,
                    axisNote: "Flee — empty house fragment, most personal",
                    sourceFragmentID: "aegean_house"
                ),
                DialogueChoice (
                    id: "aegean_flee_children",
                    text: "\"I saw children.\"\n\nYou hold his eyes.\n\n\"Go. Before the season closes.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_flee",
                    teaches: nil,
                    axisNote: "Flee — children fragment, most direct",
                    sourceFragmentID: "aegean_children"
                ),
                DialogueChoice (
                    id: "aegean_flee_salt",
                    text: "\"The smell of salt and open wind. The god shows a people who moved when they needed to.\"\n\n\"That time is now.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_flee",
                    teaches: nil,
                    axisNote: "Flee — salt air fragment",
                    sourceFragmentID: "aegean_salt"
                ),
                DialogueChoice (
                    id: "aegean_flee_word",
                    text: "\"The word the god gave me was GO.\"\n\nNothing else. You let that be enough.",
                    requires: nil,
                    leadsTo: "act2_aegean_flee",
                    teaches: nil,
                    axisNote: "Flee — GO fragment, starkest",
                    sourceFragmentID: "aegean_go"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // --- STAY WORDING ---
        DialogueNode (
            id: "act2_aegean_wording_stay",
            speaker: .mara,
            text: "The fragments give the counsel its shape.",
            choices: [
                DialogueChoice (
                    id: "aegean_stay_harbour",
                    text: "\"The god shows your harbour — busy, purposeful. The god does not counsel abandonment of one's hearth without cause.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_stay",
                    teaches: nil,
                    axisNote: "Stay — harbour fragment",
                    sourceFragmentID: "aegean_harbour"
                ),
                DialogueChoice (
                    id: "aegean_stay_house",
                    text: "\"The god shows a house that stands. Those who tend what is theirs — the god does not abandon them. Await developments.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_stay",
                    teaches: nil,
                    axisNote: "Stay — house fragment",
                    sourceFragmentID: "aegean_house"
                ),
                DialogueChoice (
                    id: "aegean_stay_salt",
                    text: "\"The salt air is your element. The god does not counsel those who know the sea to flee from it. Await developments.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_stay",
                    teaches: nil,
                    axisNote: "Stay — salt air fragment",
                    sourceFragmentID: "aegean_salt"
                ),
                DialogueChoice (
                    id: "aegean_stay_water",
                    text: "\"I saw calm water. The god does not show storm or ruin for your island — not yet. Await developments.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_stay",
                    teaches: nil,
                    axisNote: "Stay — open water fragment, false calm",
                    sourceFragmentID: "aegean_water"
                ),
                DialogueChoice (
                    id: "aegean_stay_children",
                    text: "\"I saw children at their ordinary work. The god shows ordinary life continuing. Do not abandon the hearth without cause.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_stay",
                    teaches: nil,
                    axisNote: "Stay — children fragment, false normalcy",
                    sourceFragmentID: "aegean_children"
                ),
                DialogueChoice (
                    id: "aegean_stay_word",
                    text: "\"The word the god gave me was not a word for leaving.\"\n\n\"Await developments.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_stay",
                    teaches: nil,
                    axisNote: "Stay — GO fragment withheld, most dishonest",
                    sourceFragmentID: "aegean_go"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // --- PREPARE WORDING ---
        DialogueNode (
            id: "act2_aegean_wording_prepare",
            speaker: .mara,
            text: "Something in between. The fragments give it its texture.",
            choices: [
                DialogueChoice (
                    id: "aegean_prepare_harbour",
                    text: "\"The god shows your harbour ready — not empty, not full. Prepare your vessels but do not yet sail. The answer will be clearer when the season turns.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_prepare",
                    teaches: nil,
                    axisNote: "Prepare — harbour fragment",
                    sourceFragmentID: "aegean_harbour"
                ),
                DialogueChoice (
                    id: "aegean_prepare_water",
                    text: "\"The sea is open — for now. The god counsels readiness without urgency. Prepare your vessels. Watch the season.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_prepare",
                    teaches: nil,
                    axisNote: "Prepare — open water fragment",
                    sourceFragmentID: "aegean_water"
                ),
                DialogueChoice (
                    id: "aegean_prepare_house",
                    text: "\"The god shows a house that can be left quickly and returned to. Prepare to go — but do not go yet. The season will tell you when.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_prepare",
                    teaches: nil,
                    axisNote: "Prepare — house fragment",
                    sourceFragmentID: "aegean_house"
                ),
                DialogueChoice (
                    id: "aegean_prepare_salt",
                    text: "\"The salt wind has not yet turned. The god counsels those who know the sea to read it. Prepare your vessels. It will tell you before I can.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_prepare",
                    teaches: nil,
                    axisNote: "Prepare — salt air fragment, defers to their own knowledge",
                    sourceFragmentID: "aegean_salt"
                ),
                DialogueChoice (
                    id: "aegean_prepare_children",
                    text: "\"I saw children. The god shows them safe — but the safety is not passive. It requires a decision, made in time.\"\n\n\"Prepare. Do not yet sail.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_prepare",
                    teaches: nil,
                    axisNote: "Prepare — children fragment, most protective",
                    sourceFragmentID: "aegean_children"
                ),
                DialogueChoice (
                    id: "aegean_prepare_word",
                    text: "\"The god gave me a word. I am not yet ready to speak it.\"\n\n\"Prepare your vessels. When the season turns, you will not need to ask again.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_prepare",
                    teaches: nil,
                    axisNote: "Prepare — GO fragment withheld, cryptic",
                    sourceFragmentID: "aegean_go"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // Response nodes — unchanged

        DialogueNode (
            id: "act2_aegean_flee",
            speaker: .narrator,
            text: "He exhales — a long breath he must have been holding since he left his island.\n\n\"Then we go,\" he says. \"Thank you, Oracle.\"\n\nNot Apollo's wisdom. Just thank you. Like you are a person who has helped him.\n\nIt is the hardest kind of gratitude to carry.",
            choices: nil,
            nextNodeID: "act2_corridor_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_aegean_stay",
            speaker: .narrator,
            text: "He nods carefully. He was hoping for something clearer.\n\n\"Await developments,\" he repeats, committing it to memory. He will carry those words home and four thousand people will wait for a season that will not be kind to them.\n\nYou watch him go.",
            choices: nil,
            nextNodeID: "act2_corridor_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_aegean_prepare",
            speaker: .narrator,
            text: "He bows. He is relieved to have something to bring home — even if it is not quite an answer.\n\n\"We will make ready,\" he says. \"And we will watch the season.\"\n\nIt is the best you gave him. You are not certain it was enough.",
            choices: nil,
            nextNodeID: "act2_corridor_01",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - Demetrios in the Corridor

    static let corridor: [DialogueNode] = [
        DialogueNode (
            id: "act2_corridor_01",
            speaker: .narrator,
            text: "Demetrios finds you in the corridor between the adyton and the forecourt. He walks beside you — not blocking your path, not confronting. Just walking beside.",
            choices: nil,
            nextNodeID: "act2_corridor_02",
            trigger: .enterLocation (.priestsHall),
            teaches: nil
        ),

        DialogueNode (
            id: "act2_corridor_02",
            speaker: .demetrios,
            text: "\"You did well today. The Athenians leave satisfied. The Thebans have something to work with. The island boy gets something he can use.\"\n\nA pause.\n\n\"The Oracle's role is not to tell people what will happen. It is to give them something they can act on.\"",
            choices: nil,
            nextNodeID: "act2_corridor_choice",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_corridor_choice",
            speaker: .narrator,
            text: "You walk in silence for a moment.",
            choices: [
                DialogueChoice (
                    id: "corridor_pushback",
                    text: "\"And if what they can act on is not what I actually saw?\"",
                    requires: nil,
                    leadsTo: "act2_corridor_pushback",
                    teaches: nil,
                    axisNote: "Pushes back — good"
                ),
                DialogueChoice (
                    id: "corridor_silence",
                    text: "You say nothing. You keep walking.",
                    requires: nil,
                    leadsTo: "act2_corridor_silence",
                    teaches: nil,
                    axisNote: "Silence — Demetrios notices"
                ),
                DialogueChoice (
                    id: "corridor_concede",
                    text: "\"The vision was ambiguous. You may be right about what it meant.\"",
                    requires: nil,
                    leadsTo: "act2_corridor_concede",
                    teaches: .capitulatedToDemetriosWishes,
                    axisNote: "Capitulation — integrity -2"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_corridor_pushback",
            speaker: .demetrios,
            text: "He considers this seriously. That is more unsettling than if he had dismissed it.\n\n\"The god speaks in fragments, Pythia. We are the ones who must make them whole. That has always been the Oracle's burden — and its gift.\"\n\nHe looks at you. \"You are not wrong to question it. But you are also not the first to stand where you stand and feel what you feel.\"",
            choices: nil,
            nextNodeID: "act2_corridor_end",
            trigger: nil,
            teaches: .demetriosExplainedPhilosophy
        ),

        DialogueNode (
            id: "act2_corridor_silence",
            speaker: .demetrios,
            text: "He lets the silence sit for a while. Then:\n\n\"Silence is also an answer. I have noticed that about you.\"\n\nHe does not say whether he approves.",
            choices: nil,
            nextNodeID: "act2_corridor_end",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_corridor_concede",
            speaker: .demetrios,
            text: "He nods — satisfied, but in a way that asks for nothing more from you tonight.\n\n\"Get some rest. Tomorrow the Spartan advisors arrive to scout the schedule. Leonidas himself may not be far behind.\"",
            choices: nil,
            nextNodeID: "act2_corridor_end",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_corridor_end",
            speaker: .narrator,
            text: "He leaves you at the entrance to the forecourt. The last light of the day is going.\n\nYou think about the burning ships. You think about whose they were.\n\nYou do not know. You genuinely do not know.",
            choices: nil,
            nextNodeID: "act2_niko_private_01",
            trigger: .enterLocation (.marasQuarters),
            teaches: nil
        ),
    ]

    // MARK: - Nikomedes Approaches Privately

    static let nikomedosPrivate: [DialogueNode] = [
        DialogueNode (
            id: "act2_niko_private_01",
            speaker: .narrator,
            text: "After dark, someone knocks at the door of your quarters. Not the ritual knock of a priest.\n\nNikomedes stands in the corridor. He is alone. He has left his delegation somewhere else.",
            choices: nil,
            nextNodeID: "act2_niko_private_02",
            trigger: nil,
            teaches: .nikomedosApproachedPrivately
        ),

        DialogueNode (
            id: "act2_niko_private_02",
            speaker: .nikomedes,
            text: "\"Forgive the hour. I won't keep you.\"\n\nHe steps inside without waiting for an invitation — not rudely, but as a man who has decided something and does not want to lose his nerve.\n\n\"I have been watching how this temple operates for three days. I am going to ask you something directly, as one person to another — not as an Athenian to the Oracle.\"",
            choices: nil,
            nextNodeID: "act2_niko_private_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_niko_private_03",
            speaker: .nikomedes,
            text: "\"Is the Head Priest telling you what to say?\"\n\nHe watches your face very carefully when he asks it.",
            choices: [
                DialogueChoice (
                    id: "niko_truth",
                    text: "\"He suggested an interpretation of the vision this morning. I chose whether to use it.\"",
                    requires: nil,
                    leadsTo: "act2_niko_truth",
                    teaches: .toldNikomedosTruth,
                    axisNote: "Integrity +1 — honest, opens Act IV alliance path"
                ),
                DialogueChoice (
                    id: "niko_deny",
                    text: "\"The Oracle speaks what Apollo shows. Demetrios manages the temple. They are different things.\"",
                    requires: nil,
                    leadsTo: "act2_niko_deny",
                    teaches: .toldNikomedesFalsehood,
                    axisNote: "Integrity -1 — a lie that protects the temple"
                ),
                DialogueChoice (
                    id: "niko_silence",
                    text: "You look at him for a long moment. You say nothing.",
                    requires: nil,
                    leadsTo: "act2_niko_silence",
                    teaches: .toldNikomedesNothing,
                    axisNote: "Neutral — Nikomedes draws his own conclusion"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_niko_truth",
            speaker: .nikomedes,
            text: "He is quiet for a moment.\n\n\"That is more honest than I expected.\" He does not look surprised — he looks like a man whose theory has been confirmed and who is not entirely happy about it.\n\n\"I will not use this against you. I want you to know that. What I do with it is my concern, not yours.\"",
            choices: nil,
            nextNodeID: "act2_niko_exit",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_niko_deny",
            speaker: .nikomedes,
            text: "He looks at you for a long moment.\n\n\"That is the Oracle's answer,\" he says finally. \"I came hoping for the Pythia's.\"\n\nHe bows and goes.",
            choices: nil,
            nextNodeID: "act2_niko_exit",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_niko_silence",
            speaker: .nikomedes,
            text: "He holds your gaze for a long time. Then he nods — a slow, deliberate movement.\n\n\"I thought so.\"\n\nHe straightens. \"Thank you, Pythia. In its way.\"\n\nHe goes.",
            choices: nil,
            nextNodeID: "act2_niko_exit",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_niko_exit",
            speaker: .narrator,
            text: "The door closes. You stand in your quarters alone with the lamp burning.\n\nOutside, somewhere in the forecourt, someone is already waiting for tomorrow's session.\n\nThe god, if he is here at all, offers nothing.",
            choices: nil,
            nextNodeID: "act2_close_01",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - Act II Close

    static let actClose: [DialogueNode] = [
        DialogueNode (
            id: "act2_close_01",
            speaker: .narrator,
            text: "Three days later, Lyra finds you at the Sacred Spring before the morning session.",
            choices: nil,
            nextNodeID: "act2_close_02",
            trigger: .enterLocation (.sacredSpring),
            teaches: nil
        ),

        DialogueNode (
            id: "act2_close_02",
            speaker: .lyra,
            text: "\"There is word from the road north.\"\n\nShe pauses — uncertain whether she is permitted to know this, let alone say it.\n\n\"A Spartan retinue. A small one. Moving quickly.\"\n\nShe looks at you. \"They say the king himself rides with them.\"",
            choices: nil,
            nextNodeID: "act2_close_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_close_03",
            speaker: .narrator,
            text: "You think of the vision fragments you have been collecting for weeks — a narrow pass in the mountains, red cloaks, arrows like a closing sky.\n\nThey were never about Athens.\n\nThey were never about the fleet.",
            choices: nil,
            nextNodeID: "act2_close_04",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_close_04",
            speaker: .narrator,
            text: "Demetrios will have heard the same news by now. He will already be deciding what the Oracle needs to say when Leonidas arrives.\n\nYou kneel at the spring and touch the water.\n\nIt is very cold.",
            choices: nil,
            nextNodeID: "act2_close_end",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_close_end",
            speaker: .narrator,
            text: "— ACT III —\n\nTHE PASS",
            choices: nil,
            nextNodeID: "act3_open_01",
            trigger: .actTransition (toAct: 3),
            teaches: nil
        ),
    ]

    // MARK: - Vision Fragments: The Burning Ships
    //
    // Seven fragments — higher stakes than the harvest.
    // Genuinely ambiguous: are these Greek or Persian ships?
    // Demetrios will immediately suggest an interpretation.
    //
    // Authoring note: dialogueOption is the oracle-voiced line
    // that becomes a dialogue choice in the three wording nodes
    // (act2_ships_prophecy_wording_false / _honest / _oblique).
    // Each fragment maps to one choice in each of those nodes.
    // The player selects 3 fragments → sees 3 options per wording node.

    static let burningShipsFragments: [Fragment] = [
        Fragment (
            id: "ships_fire",
            type: .image (symbolName: "flame.fill"),
            significance: "the same fire that warms and destroys — it does not choose",
            dialogueOption: "I saw ships burning on dark water. The fire does not say whose. Only that fire decides this."
        ),
        Fragment (
            id: "ships_water",
            type: .colour (hue: Color (red: 0.08, green: 0.18, blue: 0.38)),
            significance: "dark water — cold, vast, without allegiance",
            dialogueOption: "I saw dark water and fire together. The water was cold and without allegiance. It did not show me which side it held."
        ),
        Fragment (
            id: "ships_wood",
            type: .sensation (text: "the smell of\nburning timber"),
            significance: "something built over years, gone in hours",
            dialogueOption: "I smelled burning timber. Something built over years, gone in hours. I cannot tell you it was not Greek timber."
        ),
        Fragment (
            id: "ships_wind",
            type: .word (text: "HOLDS"),
            significance: "a line that does not break — or the moment before it does",
            dialogueOption: "The god showed me a line that holds — but not which line, not which fleet. Something holds. I cannot promise it is yours."
        ),
        Fragment (
            id: "ships_oar",
            type: .image (symbolName: "arrow.left.and.right"),
            significance: "movement in two directions at once — pursuit, or retreat",
            dialogueOption: "I saw movement in two directions at once — pursuit and retreat, indistinguishable. The god did not say which was yours."
        ),
        Fragment (
            id: "ships_faces",
            type: .sensation (text: "many mouths\nopening together"),
            significance: "a crowd deciding something — or being decided for",
            dialogueOption: "I saw many mouths opening together — a crowd deciding something, or being decided for. I do not know which side of that decision Athens stands on."
        ),
        Fragment (
            id: "ships_aftermath",
            type: .word (text: "AFTER"),
            significance: "not the event — what it makes possible",
            dialogueOption: "The god did not show me the battle. He showed me what comes after. I do not yet know what it costs to reach it."
        ),
    ]

    // MARK: - Vision Fragments: The Theban Roads
    //
    // Six fragments — morally heavy, geographically trapped.
    // Thebes is caught between mountains, hostile city-states, and an
    // encroaching empire. The fragments should feel like walls and closed
    // roads rather than open possibilities.
    // dialogueOption stores the honest/direct reading; gentle and uncertain
    // variants are authored inline in the wording nodes above.

    static let thebanFragments: [Fragment] = [
        Fragment (
            id: "theban_walls",
            type: .image (symbolName: "square.fill"),
            significance: "enclosed on every side — the world narrowed to a room with no door",
            dialogueOption: "The god shows walls on every side. Not one of them yields. The road you are looking for is not in this vision."
        ),
        Fragment (
            id: "theban_crossroads",
            type: .image (symbolName: "arrow.triangle.branch"),
            significance: "a choice already made — one path was ash before you arrived",
            dialogueOption: "I saw a crossroads where one path was already ash. The god shows no path that preserves a man by selling his neighbours."
        ),
        Fragment (
            id: "theban_fire",
            type: .colour (hue: Color (red: 0.80, green: 0.28, blue: 0.10)),
            significance: "fire from two directions at once — no road between them",
            dialogueOption: "Fire from two directions at once. There is no road between them that does not pass through it."
        ),
        Fragment (
            id: "theban_crowd",
            type: .sensation (text: "many people\ndeciding something\ntogether"),
            significance: "a people choosing — and carrying what they chose together afterward",
            dialogueOption: "I saw a crowd that chose together — and what they chose, they carried together afterward. That is not a road Apollo shows."
        ),
        Fragment (
            id: "theban_remains",
            type: .word (text: "REMAINS"),
            significance: "not what survives — what is left when everything else is gone",
            dialogueOption: "The word the god gave me was REMAINS. What remains after the road you are describing — I will not speak aloud."
        ),
        Fragment (
            id: "theban_mountain",
            type: .sensation (text: "stone that does not\nmove for anyone"),
            significance: "indifferent weight — geography as judgment",
            dialogueOption: "I saw mountains that do not move for anyone. The god is not showing me a path through them. He is showing me that they are there."
        ),
        Fragment (
            id: "theban_season",
            type: .word (text: "AFTER"),
            significance: "the season that follows — unclear whether Thebes is in it",
            dialogueOption: "The season turns. What is impossible now may open later. The god does not close all doors at once."
        ),
        Fragment (
            id: "theban_water",
            type: .colour (hue: Color (red: 0.30, green: 0.38, blue: 0.45)),
            significance: "still water — waiting, without direction",
            dialogueOption: "Still water finds its own level. The god shows Thebes enduring — not how, not yet. But enduring."
        ),
    ]

    // MARK: - Vision Fragments: The Aegean Island
    //
    // Six fragments — small, coastal, domestic.
    // Four thousand people on an island. The vision should feel intimate
    // and frightened rather than grand. Harbours, children, empty houses,
    // the smell of salt. These are not the fragments of empire — they are
    // the fragments of ordinary life that empire is about to reach.

    static let aegeanFragments: [Fragment] = [
        Fragment (
            id: "aegean_harbour",
            type: .image (symbolName: "ferry"),
            significance: "a harbour — empty, or full, or waiting to be one of those things",
            dialogueOption: "I saw your harbour empty. The god showed it to me after — when the choice had already been made, and the choice was right."
        ),
        Fragment (
            id: "aegean_water",
            type: .colour (hue: Color (red: 0.22, green: 0.42, blue: 0.58)),
            significance: "open water — the sea as possibility or as danger, indistinguishable",
            dialogueOption: "The sea will be safer than the shore this season. I saw open water and I saw people on it — moving away from something that was coming."
        ),
        Fragment (
            id: "aegean_house",
            type: .image (symbolName: "house"),
            significance: "a house that stands after the people inside it have gone",
            dialogueOption: "I saw an empty house. The god showed it standing — undamaged, waiting. The house survives if the people are not in it."
        ),
        Fragment (
            id: "aegean_children",
            type: .sensation (text: "the sound of\nchildren at work"),
            significance: "ordinary life — the thing that is actually being decided for",
            dialogueOption: "I saw children. Go. Before the season closes."
        ),
        Fragment (
            id: "aegean_salt",
            type: .sensation (text: "salt air\nand open wind"),
            significance: "the sea's own language — for those who know how to read it",
            dialogueOption: "The smell of salt and open wind. The god shows a people who moved when they needed to. That time is now."
        ),
        Fragment (
            id: "aegean_go",
            type: .word (text: "GO"),
            significance: "one word — clear enough that no amount of Oracle tradition could soften it",
            dialogueOption: "The word the god gave me was GO."
        ),
    ]
}
