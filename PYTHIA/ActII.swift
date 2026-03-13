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
// Connect: in ActI.swift, set act1_close_end.nextNodeID = "act2_open_01"
// and update ContentView to pass ActI.nodes + ActII.nodes to NarrativeEngine.

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

        DialogueNode (
            id: "act2_demetrios_intercept_02",
            speaker: .narrator,
            text: "He withdraws before you can respond.\n\nYou saw burning ships. You did not see whose they were.\n\nNikomedes waits.",
            choices: [
                DialogueChoice (
                    id: "ships_follow_demetrios",
                    text: "\"The god shows Greek ships driving Persian fire from the harbour. Your fleet will hold.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_followed",
                    teaches: .capitulatedToDemetriosWishes,
                    axisNote: "Follows Demetrios — integrity -2"
                ),
                DialogueChoice (
                    id: "ships_honest",
                    text: "\"I saw ships burning on dark water. Whose ships — the god does not say. Only that fire decides this.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_honest",
                    teaches: .spokeAgainstDemetriosWishes,
                    axisNote: "Honest ambiguity — integrity +2"
                ),
                DialogueChoice (
                    id: "ships_oblique",
                    text: "\"The wooden walls will hold what bronze cannot. Athens knows where its strength lies.\"",
                    requires: nil,
                    leadsTo: "act2_athenian_oblique",
                    teaches: .usedOracularAmbiguityAsShield,
                    axisNote: "Traditional riddle — integrity -1"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

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
            text: "He studies you for a long moment — long enough to make clear he is deciding something.\n\n\"Wooden walls,\" he says finally. \"Yes. That will do.\"\n\nIt is not a grateful response. It is a man who came expecting one thing and received another, and is deciding what to do about it.",
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
            nextNodeID: "act2_theban_01",
            trigger: nil,
            teaches: .receivedThebanDelegation
        ),

        DialogueNode (
            id: "act2_theban_01",
            speaker: .narrator,
            text: "\"Great Oracle.\" Pausanias is a man choosing his words with enormous care. \"Thebes asks only this — is there a path that preserves our people? Any path. The god sees all roads. We need only one.\"",
            choices: nil,
            nextNodeID: "act2_theban_choice",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_theban_choice",
            speaker: .narrator,
            text: "He is asking whether Thebes can surrender to Persia and survive.\n\nHe is asking you to tell him it will be all right to betray Greece.",
            choices: [
                DialogueChoice (
                    id: "theban_hard_truth",
                    text: "\"The god shows no path that preserves a man by selling his neighbours. That is not a road Apollo walks.\"",
                    requires: nil,
                    leadsTo: "act2_theban_hard",
                    teaches: .spokeDirectTruthAtPersonalCost,
                    axisNote: "Integrity +2 — direct moral clarity"
                ),
                DialogueChoice (
                    id: "theban_gentle",
                    text: "\"Some roads that look open are closed before you reach them. The god counsels patience over speed.\"",
                    requires: nil,
                    leadsTo: "act2_theban_gentle",
                    teaches: .usedOracularAmbiguityAsShield,
                    axisNote: "Integrity -1 — not quite a lie but not truth either"
                ),
                DialogueChoice (
                    id: "theban_uncertain",
                    text: "\"I cannot see the road you are describing. That may be answer enough.\"",
                    requires: nil,
                    leadsTo: "act2_theban_uncertain",
                    teaches: nil,
                    axisNote: "Neutral — honest about the limits of the vision"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

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
            nextNodeID: "act2_aegean_01",
            trigger: nil,
            teaches: .receivedAegeanDelegation
        ),

        DialogueNode (
            id: "act2_aegean_01",
            speaker: .narrator,
            text: "\"Oracle.\" His voice is steady. He has practised this. \"We have no allies who will come for us. If the Persian fleet moves through the Aegean, we cannot fight. Our council asks — should we flee now, before the season closes, or is there reason to stay?\"",
            choices: nil,
            nextNodeID: "act2_aegean_choice",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act2_aegean_choice",
            speaker: .narrator,
            text: "This is simpler than it looks. He is asking you to tell four thousand people whether to abandon their homes.\n\nYou think of the burning ships. You think of the narrow pass you keep seeing at the edges of visions, just out of focus.",
            choices: [
                DialogueChoice (
                    id: "aegean_flee",
                    text: "\"Go. The sea will be safer than the shore this season. Do not wait for confirmation.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_flee",
                    teaches: .spokeDirectTruthAtPersonalCost,
                    axisNote: "Integrity +2 — clear, actionable, costly"
                ),
                DialogueChoice (
                    id: "aegean_stay",
                    text: "\"The god does not counsel abandonment of one's hearth without cause. Await developments.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_stay",
                    teaches: .capitulatedToDemetriosWishes,
                    axisNote: "Integrity -2 — Demetrios wants stability, not evacuations"
                ),
                DialogueChoice (
                    id: "aegean_prepare",
                    text: "\"Prepare your vessels but do not yet sail. The answer will be clearer when the season turns.\"",
                    requires: nil,
                    leadsTo: "act2_aegean_prepare",
                    teaches: nil,
                    axisNote: "Neutral — buys time, gives no real guidance"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

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

        // Act II end node — links to Act III
        DialogueNode (
            id: "act2_close_end",
            speaker: .narrator,
            text: "— ACT III —\n\nTHE PASS",
            choices: nil,
            nextNodeID: nil,    // Will link to act3_open_01 when Act III is built
            trigger: .actTransition (toAct: 3),
            teaches: nil
        ),
    ]

    // MARK: - Vision Fragments: The Burning Ships
    //
    // The second vision — higher stakes than the harvest.
    // Genuinely ambiguous: are these Greek or Persian ships?
    // Demetrios will immediately suggest an interpretation.
    // The player's fragment selection seeds the prophecy choices that follow.

    static let burningShipsFragments: [Fragment] = [
        Fragment (
            id: "ships_fire",
            type: .image (symbolName: "flame.fill"),
            significance: "the same fire that warms and destroys — it does not choose"
        ),
        Fragment (
            id: "ships_water",
            type: .colour (hue: Color (red: 0.08, green: 0.18, blue: 0.38)),
            significance: "dark water — cold, vast, without allegiance"
        ),
        Fragment (
            id: "ships_wood",
            type: .sensation (text: "the smell of\nburning timber"),
            significance: "something built over years, gone in hours"
        ),
        Fragment (
            id: "ships_wind",
            type: .word (text: "HOLDS"),
            significance: "a line that does not break — or the moment before it does"
        ),
        Fragment (
            id: "ships_oar",
            type: .image (symbolName: "arrow.left.and.right"),
            significance: "movement in two directions at once — pursuit, or retreat"
        ),
        Fragment (
            id: "ships_faces",
            type: .sensation (text: "many mouths\nopening together"),
            significance: "a crowd deciding something — or being decided for"
        ),
        Fragment (
            id: "ships_aftermath",
            type: .word (text: "AFTER"),
            significance: "not the event — what it makes possible"
        ),
    ]
}
