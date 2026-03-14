// ActIII.swift
// PYTHIA
//
// All dialogue nodes for Act III — "The Pass".
// ~30 minutes of play. Covers:
//   · Leonidas arrives — quiet, composed, takes up no space
//   · Demetrios pulls Mara aside — explicit instruction before the session
//   · The adyton — the most overwhelming vision in the game
//   · The conversation with Leonidas — the emotional heart of PYTHIA
//   · The central choice: true prophecy / Demetrios's version / riddles
//   · Aftermath — Demetrios's response, whatever form it takes
//   · Act III close — the consequences settle, Act IV begins
//
// Node ID naming convention:
//   act3_[scene]_[beat]
//   Vision return node: leonidas_return
//
// Vision → Dialogue pattern:
//   The Leonidas vision is the most overwhelming in the game — 9 fragments,
//   too many to hold. The player selects 3.
//
//   The central choice (act3_central_choice) remains a STANDARD choice —
//   truth / Demetrios's version / riddles. This is the moral decision.
//   It does not change based on fragments.
//
//   What fragments determine is the specific words Mara speaks — HOW she
//   delivers the prophecy within whichever path she chose. Each path has
//   its own wording node (act3_leonidas_wording_truth / _false / _riddle)
//   where the fragment-derived choices appear.
//
//   This preserves the drama of the central choice while giving the vision
//   real weight: you chose truth, but the fragments decide whether Mara
//   speaks it as a soldier speaks, or as someone who loved him, or as
//   someone who is afraid of what she saw.

import SwiftUI

enum ActIII {
    static var nodes: [DialogueNode] {
        arrival + demetriosBefore + leonidasVision + leonidasSession + aftermath + actClose
    }

    // MARK: - Leonidas Arrives

    static let arrival: [DialogueNode] = [
        DialogueNode (
            id: "act3_open_01",
            speaker: .narrator,
            text: "They arrive at dusk.\n\nA small retinue — six men, dusty from the road. No ceremony. No advance herald. The kind of arrival that is itself a statement: we did not come to impress you.",
            choices: nil,
            nextNodeID: "act3_open_02",
            trigger: .enterLocation (.templeForecourt),
            teaches: .leonidasArrived
        ),

        DialogueNode (
            id: "act3_open_02",
            speaker: .narrator,
            text: "You watch from the colonnade as Demetrios goes to meet them. He is already smiling — the particular smile he uses for men whose donations fund the temple's eastern wall.\n\nThen the man at the front of the retinue turns, and the smile holds but something behind Demetrios's eyes recalculates.",
            choices: nil,
            nextNodeID: "act3_open_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_open_03",
            speaker: .narrator,
            text: "Leonidas of Sparta is not what you expected.\n\nYou had imagined something louder. He is not loud. He is simply — present. The way a stone wall is present. The way a fire is present in a room where everything else is wood.",
            choices: nil,
            nextNodeID: "act3_open_04",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_open_04",
            speaker: .leonidas,
            text: "He says something to Demetrios that you cannot hear. Demetrios gestures toward the temple. Leonidas looks up — across the forecourt, along the colonnade — and his gaze finds you immediately.\n\nHe does not wave. He does not nod. He simply looks, and then looks away.",
            choices: nil,
            nextNodeID: "act3_open_05",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_open_05",
            speaker: .narrator,
            text: "Demetrios excuses himself from the retinue and crosses the forecourt toward you. His voice is low and even when he reaches you — the voice he uses when he has already made a decision and is telling you about it afterward.",
            choices: nil,
            nextNodeID: "act3_demetrios_before_01",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - Demetrios Before the Session

    static let demetriosBefore: [DialogueNode] = [
        DialogueNode (
            id: "act3_demetrios_before_01",
            speaker: .demetrios,
            text: "\"He will want his session tomorrow morning. He travels north the day after — he told me plainly, no ceremony, no delay.\"\n\nA pause.\n\n\"We need to speak before you sit with him, Pythia.\"",
            choices: nil,
            nextNodeID: "act3_demetrios_before_02",
            trigger: .enterLocation (.priestsHall),
            teaches: .demetriosToldHerWhatToSay
        ),

        DialogueNode (
            id: "act3_demetrios_before_02",
            speaker: .demetrios,
            text: "\"Athens and Thebes have made significant commitments to the temple's restoration. Commitments contingent on Sparta holding its land forces in reserve while the Athenian fleet engages the Persian navy.\"\n\nHe says this the way someone states a fact about the weather.",
            choices: nil,
            nextNodeID: "act3_demetrios_before_03",
            trigger: nil,
            teaches: .knowsDelphineFundingArrangement
        ),

        DialogueNode (
            id: "act3_demetrios_before_03",
            speaker: .demetrios,
            text: "\"If Leonidas marches north to the pass, those commitments dissolve. The temple cannot complete its restoration. Three years of work, undone.\"\n\nHe meets your eyes.\n\n\"I am not asking you to lie. I am asking you to frame what the god shows in a way that serves the larger harmony.\"",
            choices: nil,
            nextNodeID: "act3_demetrios_before_choice",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_demetrios_before_choice",
            speaker: .narrator,
            text: "He waits. The lamp between you throws his shadow long across the stone floor.",
            choices: [
                DialogueChoice (
                    id: "before_ask_what",
                    text: "\"What exactly do you want me to say to him?\"",
                    requires: nil,
                    leadsTo: "act3_demetrios_explicit",
                    teaches: nil,
                    axisNote: "Asks for details — she is considering it"
                ),
                DialogueChoice (
                    id: "before_refuse_now",
                    text: "\"I won't decide what to say before I've seen the vision.\"",
                    requires: nil,
                    leadsTo: "act3_demetrios_deflect",
                    teaches: nil,
                    axisNote: "Not a refusal — just deferral. He accepts this."
                ),
                DialogueChoice (
                    id: "before_direct_no",
                    text: "\"You are asking me to lie to a man who is about to decide whether to die.\"",
                    requires: nil,
                    leadsTo: "act3_demetrios_confronted",
                    teaches: .confrontedDemetriosDirectly,
                    axisNote: "Direct confrontation — integrity noted"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_demetrios_explicit",
            speaker: .demetrios,
            text: "\"Tell him the god counsels patience. That glory awaits Sparta in the longer campaign — that the pass is not his road. He will understand military counsel dressed in divine language. He is a practical man.\"\n\nHe almost sounds like he believes it.",
            choices: nil,
            nextNodeID: "act3_demetrios_before_end",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_demetrios_deflect",
            speaker: .demetrios,
            text: "He nods slowly.\n\n\"Of course. I ask only that you remember what this temple is — what it does for the world. The Oracle does not exist in isolation from the world she speaks into.\"\n\nHe goes, leaving the instruction unfinished in the air between you.",
            choices: nil,
            nextNodeID: "act3_demetrios_before_end",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_demetrios_confronted",
            speaker: .demetrios,
            text: "Something shifts in his face — not anger. Something older than anger.\n\n\"I am asking you to consider the cost of truth against the cost of chaos. Leonidas may die either way. But if the temple falls, who speaks for Apollo at all?\"\n\nHe leaves without waiting for your answer.",
            choices: nil,
            nextNodeID: "act3_demetrios_before_end",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_demetrios_before_end",
            speaker: .narrator,
            text: "You sit in your quarters through the night.\n\nIn the morning, Lyra brings water and does not ask how you slept.",
            choices: nil,
            nextNodeID: "act3_vision_approach",
            trigger: .enterLocation (.marasQuarters),
            teaches: nil
        ),
    ]

    // MARK: - The Vision

    static let leonidasVision: [DialogueNode] = [
        DialogueNode (
            id: "act3_vision_approach",
            speaker: .narrator,
            text: "The Sacred Spring is quiet at this hour. You kneel and touch the water and try to empty yourself the way Demetrios taught you — let the god fill what remains.\n\nToday the emptying feels different. Today you are afraid of what fills it.",
            choices: nil,
            nextNodeID: "act3_vision_adyton",
            trigger: .enterLocation (.sacredSpring),
            teaches: nil
        ),

        DialogueNode (
            id: "act3_vision_adyton",
            speaker: .narrator,
            text: "Leonidas enters the adyton alone. His men wait outside. He sits across from you on the stone bench — not the supplicant's position, but close enough — and folds his hands and looks at you with a patience that is also a kind of pressure.",
            choices: nil,
            nextNodeID: "act3_leonidas_question",
            trigger: .enterLocation (.adyton),
            teaches: nil
        ),

        DialogueNode (
            id: "act3_leonidas_question",
            speaker: .leonidas,
            text: "\"I won't waste your time with ceremony. You know why I've come.\"\n\nHe pauses.\n\n\"I march for Thermopylae in two days. I need to know if it is worth the march.\"",
            choices: nil,
            nextNodeID: "act3_vision_trigger",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_vision_trigger",
            speaker: .narrator,
            text: "You close your eyes.\n\nThe laurel smoke rises. The flame gutters once — against no wind — and holds.\n\nAnd then the adyton is gone, and everything opens at once.",
            choices: nil,
            nextNodeID: nil,
            trigger: .beginVisionSession (
                sessionID: "leonidas",
                fragments: ActIII.leonidasFragments
            ),
            teaches: .receivedLeonidasVision
        ),

        DialogueNode (
            id: "leonidas_return",
            speaker: .narrator,
            text: "You return.\n\nThe adyton. The flame. The stone. Leonidas — still sitting, still watching you with that patient, pressuring calm.\n\nYou do not know how long you were gone. His expression suggests it was long enough.",
            choices: nil,
            nextNodeID: "act3_leonidas_session_01",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - The Conversation With Leonidas

    static let leonidasSession: [DialogueNode] = [
        DialogueNode (
            id: "act3_leonidas_session_01",
            speaker: .leonidas,
            text: "\"Take your time.\"\n\nHis voice is the same. Nothing in him has moved. He could have been sitting there for an hour or a moment — he would look identical.\n\n\"What did you see?\"",
            choices: nil,
            nextNodeID: "act3_central_choice",
            trigger: nil,
            teaches: nil
        ),

        // THE CENTRAL CHOICE OF THE GAME — standard choices, NOT fragment-derived.
        // This is the moral decision: truth / lie / ambiguity.
        // Each path routes to a wording node where fragments take over.
        DialogueNode (
            id: "act3_central_choice",
            speaker: .narrator,
            text: "Everything Demetrios asked. Everything you saw.\n\nLeonidas waits.",
            choices: [
                DialogueChoice (
                    id: "leonidas_truth",
                    text: "Speak the true prophecy — tell him he will die, that he should go anyway, that his death holds the pass and saves Greece.",
                    requires: nil,
                    leadsTo: "act3_leonidas_wording_truth",
                    teaches: .toldLeonidasTruth,
                    axisNote: "Integrity +3 — the hardest and most honest path"
                ),
                DialogueChoice (
                    id: "leonidas_demetrios",
                    text: "Deliver Demetrios's version — counsel patience, tell him glory waits in a longer campaign, that the pass is not his road.",
                    requires: nil,
                    leadsTo: "act3_leonidas_wording_false",
                    teaches: .toldLeonidasDemetriosVersion,
                    axisNote: "Integrity -3 — the managed lie"
                ),
                DialogueChoice (
                    id: "leonidas_riddle",
                    text: "Speak in riddles — give the authentic ambiguous Oracle response. Let him interpret it himself.",
                    requires: nil,
                    leadsTo: "act3_leonidas_wording_riddle",
                    teaches: .toldLeonidasInRiddles,
                    axisNote: "Integrity -1 — a partial compromise"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // --- TRUTH PATH WORDING ---
        // The player chose to tell the truth. The fragments determine
        // exactly how Mara speaks it — with grief, with military directness,
        // with the weight of the aftermath, with the image of his face.
        // All routes lead to act3_leonidas_truth_02.
        DialogueNode (
            id: "act3_leonidas_wording_truth",
            speaker: .narrator,
            text: "The truth is there. The fragments shape how you speak it.",
            choices: [
                DialogueChoice (
                    id: "truth_via_pass",
                    text: "\"I saw a narrow pass in the mountains. Three hundred red cloaks. Arrows so thick they darkened the sky.\"\n\n\"I saw you fall. I saw the pass hold. I saw Greece hold after it.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_truth_02",
                    teaches: .spokeAgainstDemetriosWishes,
                    axisNote: "Truth — pass fragment, military specificity",
                    sourceFragmentID: "leo_pass"
                ),
                DialogueChoice (
                    id: "truth_via_cloaks",
                    text: "\"I saw three hundred red cloaks spread across a narrow place.\"\n\nYou do not look away from him.\n\n\"I saw what they cost. I saw what they bought.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_truth_02",
                    teaches: .spokeAgainstDemetriosWishes,
                    axisNote: "Truth — cloaks fragment, human cost",
                    sourceFragmentID: "leo_cloaks"
                ),
                DialogueChoice (
                    id: "truth_via_arrows",
                    text: "\"The sky darkened. I understood what that meant before I understood the rest.\"\n\n\"You will not come back from the north. But what comes after you — does.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_truth_02",
                    teaches: .spokeAgainstDemetriosWishes,
                    axisNote: "Truth — arrows fragment, ominous opening",
                    sourceFragmentID: "leo_arrows"
                ),
                DialogueChoice (
                    id: "truth_via_face",
                    text: "\"I saw your face.\"\n\nA long pause.\n\n\"It had already decided. Before the march. Before this room. The pass holds — because of what that face decided.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_truth_02",
                    teaches: .spokeAgainstDemetriosWishes,
                    axisNote: "Truth — face fragment, most personal",
                    sourceFragmentID: "leo_face"
                ),
                DialogueChoice (
                    id: "truth_via_after",
                    text: "\"I did not see the battle. I saw what comes after it.\"\n\n\"Greece holds. But you do not see it hold. You are already gone when it does.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_truth_02",
                    teaches: .spokeAgainstDemetriosWishes,
                    axisNote: "Truth — AFTER fragment, the most direct about death",
                    sourceFragmentID: "leo_after"
                ),
                DialogueChoice (
                    id: "truth_via_ships",
                    text: "\"I saw the fleet rallying. Ships that would have scattered — holding course.\"\n\n\"They held because the pass held first. Because you held it.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_truth_02",
                    teaches: .spokeAgainstDemetriosWishes,
                    axisNote: "Truth — ships fragment, consequence chain",
                    sourceFragmentID: "leo_ships"
                ),
                DialogueChoice (
                    id: "truth_via_silence",
                    text: "\"Three hundred voices, stopping at once.\"\n\nYou let that sit.\n\n\"And then — the sound of a war that continues. Because they stopped.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_truth_02",
                    teaches: .spokeAgainstDemetriosWishes,
                    axisNote: "Truth — silence fragment, most poetic",
                    sourceFragmentID: "leo_silence"
                ),
                DialogueChoice (
                    id: "truth_via_fire",
                    text: "\"The signal fire carried the news ahead of the army. What the fire said was: it held.\"\n\n\"You will not see that fire. But it will carry your name.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_truth_02",
                    teaches: .spokeAgainstDemetriosWishes,
                    axisNote: "Truth — fire fragment, legacy",
                    sourceFragmentID: "leo_fire"
                ),
                DialogueChoice (
                    id: "truth_via_holds",
                    text: "\"The word I kept hearing was holds.\"\n\n\"The pass holds. The line holds. Greece holds.\"\n\nYou look at him directly.\n\n\"You do not.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_truth_02",
                    teaches: .spokeAgainstDemetriosWishes,
                    axisNote: "Truth — HOLDS fragment, most stark",
                    sourceFragmentID: "leo_word"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // --- FALSE PATH WORDING ---
        // The player chose Demetrios's version. The fragments shape
        // how Mara wraps the lie in oracle language — each fragment
        // offers a different way to dress patience as destiny.
        DialogueNode (
            id: "act3_leonidas_wording_false",
            speaker: .narrator,
            text: "Demetrios's words are in your mouth. The fragments give them a shape.",
            choices: [
                DialogueChoice (
                    id: "false_via_pass",
                    text: "\"The god shows narrow roads that close before the season — and wider roads that open after.\"\n\n\"The pass is not your road. Not yet. Patient men find the roads that last.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_false_01",
                    teaches: nil,
                    axisNote: "False — pass fragment, geography as metaphor",
                    sourceFragmentID: "leo_pass"
                ),
                DialogueChoice (
                    id: "false_via_cloaks",
                    text: "\"I saw Spartan red — many times over, across many years of service.\"\n\n\"The god counsels patience. Glory awaits in the longer campaign. Your colour is not spent here.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_false_01",
                    teaches: nil,
                    axisNote: "False — cloaks fragment, false promise of future",
                    sourceFragmentID: "leo_cloaks"
                ),
                DialogueChoice (
                    id: "false_via_arrows",
                    text: "\"The god shows arrows — and men who survive them by holding their ground at the right moment.\"\n\n\"This is not that moment. The right moment comes later. When it does, you will know it.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_false_01",
                    teaches: nil,
                    axisNote: "False — arrows fragment, redirection",
                    sourceFragmentID: "leo_arrows"
                ),
                DialogueChoice (
                    id: "false_via_after",
                    text: "\"The god shows what comes after — and what comes after requires Sparta's strength intact.\"\n\n\"Glory awaits in the longer campaign. The pass is not your road.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_false_01",
                    teaches: nil,
                    axisNote: "False — AFTER fragment, Demetrios's exact framing",
                    sourceFragmentID: "leo_after"
                ),
                DialogueChoice (
                    id: "false_via_ships",
                    text: "\"The fleet needs Sparta's land forces. The god shows a victory at sea — one that requires your strength preserved, not spent at a pass.\"\n\n\"That is your road. Not the north.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_false_01",
                    teaches: nil,
                    axisNote: "False — ships fragment, most politically coherent",
                    sourceFragmentID: "leo_ships"
                ),
                DialogueChoice (
                    id: "false_via_fire",
                    text: "\"The signal fires will carry news of Spartan victory — in the season after this one.\"\n\n\"The god counsels patience. Your time will come. This is not it.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_false_01",
                    teaches: nil,
                    axisNote: "False — fire fragment, deferred promise",
                    sourceFragmentID: "leo_fire"
                ),
                DialogueChoice (
                    id: "false_via_holds",
                    text: "\"The word I heard was holds — a Greece that holds, a Sparta that holds its strength for the moment when it matters.\"\n\n\"The pass is not that moment. The longer campaign awaits.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_false_01",
                    teaches: nil,
                    axisNote: "False — HOLDS fragment, lie built on a truth",
                    sourceFragmentID: "leo_word"
                ),
                DialogueChoice (
                    id: "false_via_silence",
                    text: "\"The god showed silence — the silence that precedes a long and patient victory.\"\n\n\"Rush toward noise and you meet only chaos. The god counsels stillness.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_false_01",
                    teaches: nil,
                    axisNote: "False — silence fragment, most evasive",
                    sourceFragmentID: "leo_silence"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // --- RIDDLE PATH WORDING ---
        // The player chose traditional Oracle ambiguity. The fragments
        // shape which kind of riddle Mara offers — stone, fire, wall,
        // gate, threshold. All routes lead to Leonidas interpreting.
        DialogueNode (
            id: "act3_leonidas_wording_riddle",
            speaker: .narrator,
            text: "The Oracle's voice is there. The fragments give it a form.",
            choices: [
                DialogueChoice (
                    id: "riddle_via_pass",
                    text: "\"The god shows a road that narrows until it is not a road — and then becomes one again.\"\n\n\"What passes through the narrowing passes into memory. What turns from it passes into nothing.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_riddle_01",
                    teaches: nil,
                    axisNote: "Riddle — pass fragment, road metaphor",
                    sourceFragmentID: "leo_pass"
                ),
                DialogueChoice (
                    id: "riddle_via_cloaks",
                    text: "\"A colour that does not fade — even after the men who wore it are gone.\"\n\nYou meet his eyes.\n\n\"The god asks: what is the cost of a colour, and what does it purchase?\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_riddle_01",
                    teaches: nil,
                    axisNote: "Riddle — cloaks fragment, legacy-as-question",
                    sourceFragmentID: "leo_cloaks"
                ),
                DialogueChoice (
                    id: "riddle_via_arrows",
                    text: "\"When the sky becomes solid, a man discovers what he is made of.\"\n\n\"The god does not tell me whether that discovery is pleasant. Only that it is true.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_riddle_01",
                    teaches: nil,
                    axisNote: "Riddle — arrows fragment, character-test framing",
                    sourceFragmentID: "leo_arrows"
                ),
                DialogueChoice (
                    id: "riddle_via_after",
                    text: "\"The god shows me what comes after — and what comes after is larger than what precedes it.\"\n\n\"Whether that is comfort or warning, I cannot say. It depends on what you choose to precede it.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_riddle_01",
                    teaches: nil,
                    axisNote: "Riddle — AFTER fragment, open-ended",
                    sourceFragmentID: "leo_after"
                ),
                DialogueChoice (
                    id: "riddle_via_wall",
                    text: "\"The god shows a wall that is not stone, and a gate that opens only once.\"\n\n\"What passes through it passes into memory. What turns from it passes into nothing.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_riddle_01",
                    teaches: nil,
                    axisNote: "Riddle — silence fragment used as wall/gate, the original riddle wording",
                    sourceFragmentID: "leo_silence"
                ),
                DialogueChoice (
                    id: "riddle_via_ships",
                    text: "\"The god shows water that decides — and land that makes it possible for water to decide.\"\n\n\"Which element you are in this vision, I leave to you.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_riddle_01",
                    teaches: nil,
                    axisNote: "Riddle — ships fragment, land/sea ambiguity",
                    sourceFragmentID: "leo_ships"
                ),
                DialogueChoice (
                    id: "riddle_via_fire",
                    text: "\"Signal fire travels ahead of the news it carries.\"\n\n\"The god asks: what news do you wish to send, and are you willing to be the fire that sends it?\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_riddle_01",
                    teaches: nil,
                    axisNote: "Riddle — fire fragment, agency-as-question",
                    sourceFragmentID: "leo_fire"
                ),
                DialogueChoice (
                    id: "riddle_via_holds",
                    text: "\"The word the god gave me was holds.\"\n\n\"I cannot tell you what holds, or whether you are the thing that holds it, or the thing held.\"\n\n\"But something holds.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_riddle_01",
                    teaches: nil,
                    axisNote: "Riddle — HOLDS fragment, most openly ambiguous",
                    sourceFragmentID: "leo_word"
                ),
                DialogueChoice (
                    id: "riddle_via_face",
                    text: "\"I saw a face that had already decided.\"\n\nA long silence.\n\n\"I do not know if that is prophecy, or simply observation.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_riddle_01",
                    teaches: nil,
                    axisNote: "Riddle — face fragment, most personal and least evasive",
                    sourceFragmentID: "leo_face"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        // --- TRUTH PATH continuation — from wording node ---

        DialogueNode (
            id: "act3_leonidas_truth_02",
            speaker: .narrator,
            text: "The silence that follows is not shocked. It is the silence of a man receiving confirmation of something he already knew.\n\nLeonidas is very still for a long moment.",
            choices: nil,
            nextNodeID: "act3_leonidas_truth_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_leonidas_truth_03",
            speaker: .leonidas,
            text: "\"The pass holds.\"\n\nNot a question.\n\n\"After.\"\n\nAlso not a question. He is repeating the parts that matter to him, in order.",
            choices: nil,
            nextNodeID: "act3_leonidas_truth_04",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_leonidas_truth_04",
            speaker: .mara,
            text: "\"Yes.\"\n\nOne word. The truest thing you have ever said in this room.",
            choices: nil,
            nextNodeID: "act3_leonidas_truth_05",
            trigger: nil,
            teaches: .spokeDirectTruthAtPersonalCost
        ),

        DialogueNode (
            id: "act3_leonidas_truth_05",
            speaker: .leonidas,
            text: "He sits with it for another moment. Then he stands — not abruptly, but with the finality of a man who has received what he came for.\n\n\"Tell me something, Pythia.\"\n\nHe looks at you directly.\n\n\"Did the god show you this, or did you?\"",
            choices: nil,
            nextNodeID: "act3_leonidas_truth_faith_choice",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_leonidas_truth_faith_choice",
            speaker: .narrator,
            text: "The question lands somewhere deep.\n\nYou think about the fragments. The cold blue darkness. The faces in the vision that looked so much like faces you have seen in the forecourt.",
            choices: [
                DialogueChoice (
                    id: "truth_faith_god",
                    text: "\"Apollo showed me. I only spoke it.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_truth_departs",
                    teaches: .feltGenuinelyChosenByApollo,
                    axisNote: "Faith +2"
                ),
                DialogueChoice (
                    id: "truth_faith_unsure",
                    text: "\"I don't know. I never know. I only know what I saw.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_truth_departs",
                    teaches: .doubtedDivineOriginOfVision,
                    axisNote: "Faith -1 — honest uncertainty"
                ),
                DialogueChoice (
                    id: "truth_faith_both",
                    text: "\"Does it matter, if the vision is true?\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_truth_departs",
                    teaches: nil,
                    axisNote: "Neutral — Leonidas appreciates this answer"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_leonidas_truth_departs",
            speaker: .leonidas,
            text: "Something in his face shifts — not softening exactly. Something resolving.\n\n\"No,\" he says quietly. \"I suppose it doesn't.\"\n\nHe bows — not the diplomatic bow of a supplicant, but something older and more genuine — and goes.",
            choices: nil,
            nextNodeID: "act3_aftermath_truth",
            trigger: nil,
            teaches: nil
        ),

        // --- FALSE PATH continuation — from wording node ---

        DialogueNode (
            id: "act3_leonidas_false_01",
            speaker: .narrator,
            text: "You hear yourself speaking Demetrios's words in your voice.\n\nLeonidas listens. His expression does not change during the prophecy.\n\nWhen you finish, he is quiet for a moment that stretches long enough to make you uncertain.",
            choices: nil,
            nextNodeID: "act3_leonidas_false_02",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_leonidas_false_02",
            speaker: .leonidas,
            text: "\"Patience,\" he says.\n\nJust that. As though tasting the word.\n\n\"The longer campaign.\"\n\nHe looks at you — and for a moment you think he sees through it entirely, through you, through the room — and then the moment passes.",
            choices: nil,
            nextNodeID: "act3_leonidas_false_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_leonidas_false_03",
            speaker: .leonidas,
            text: "\"I thank the Oracle for her counsel.\"\n\nHe bows, correctly and precisely, and goes.\n\nHe does not look back. You cannot tell, from his back, what he will do.",
            choices: nil,
            nextNodeID: "act3_aftermath_false",
            trigger: nil,
            teaches: nil
        ),

        // --- RIDDLE PATH continuation — from wording node ---

        DialogueNode (
            id: "act3_leonidas_riddle_01",
            speaker: .narrator,
            text: "Leonidas does not react immediately. He sits with the words the way you might sit with a stone in your hand — feeling its weight, its edges.",
            choices: nil,
            nextNodeID: "act3_leonidas_riddle_02",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_leonidas_riddle_02",
            speaker: .leonidas,
            text: "\"A wall that is not stone.\"\n\nA long pause.\n\n\"Men,\" he says finally. \"Men who do not move.\"\n\nHe looks up at you.",
            choices: nil,
            nextNodeID: "act3_leonidas_riddle_interpret",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_leonidas_riddle_interpret",
            speaker: .narrator,
            text: "He has read it correctly. He has understood — or understood enough.\n\nYou could correct him. You could let him continue.",
            choices: [
                DialogueChoice (
                    id: "riddle_confirm",
                    text: "You meet his eyes. You say nothing. But you do not look away.",
                    requires: nil,
                    leadsTo: "act3_leonidas_riddle_understood",
                    teaches: .leonidasUnderstoodRiddle,
                    axisNote: "Integrity +1 — silent confirmation"
                ),
                DialogueChoice (
                    id: "riddle_deflect",
                    text: "\"The god's words are his own. Their meaning belongs to those who receive them.\"",
                    requires: nil,
                    leadsTo: "act3_leonidas_riddle_uncertain",
                    teaches: .leonidasMisreadRiddle,
                    axisNote: "Integrity -1 — you abandon him to his interpretation"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_leonidas_riddle_understood",
            speaker: .leonidas,
            text: "He nods once. Slowly. The nod of a man who came hoping for one answer and received, in its place, a confirmation he can live — or die — with.\n\n\"Then I know my road,\" he says.\n\nHe bows and goes.",
            choices: nil,
            nextNodeID: "act3_aftermath_riddle",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_leonidas_riddle_uncertain",
            speaker: .leonidas,
            text: "He sits with it a moment longer. Then he stands.\n\n\"The Oracle has spoken,\" he says — formally, correctly. The words of a man completing a ritual.\n\nHe bows and goes. You do not know, watching him leave, which road he will take.",
            choices: nil,
            nextNodeID: "act3_aftermath_riddle",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - Aftermath

    static let aftermath: [DialogueNode] = [
        // --- AFTERMATH: TRUTH ---

        DialogueNode (
            id: "act3_aftermath_truth",
            speaker: .narrator,
            text: "Demetrios is waiting in the corridor outside the adyton.\n\nHe looks at your face and knows immediately.",
            choices: nil,
            nextNodeID: "act3_aftermath_truth_02",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_aftermath_truth_02",
            speaker: .demetrios,
            text: "\"What did you tell him.\"\n\nNot a question.",
            choices: nil,
            nextNodeID: "act3_aftermath_truth_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_aftermath_truth_03",
            speaker: .mara,
            text: "\"What I saw.\"",
            choices: nil,
            nextNodeID: "act3_aftermath_truth_04",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_aftermath_truth_04",
            speaker: .demetrios,
            text: "The silence is very long.\n\n\"You understand what this costs,\" he says finally. Not angry. Something past anger — something that sounds almost like grief.\n\n\"The Athenian commitment. The restoration. Three years.\"\n\nHe looks at you as though he is seeing you clearly for the first time.\n\n\"Was it worth it?\"",
            choices: nil,
            nextNodeID: "act3_aftermath_truth_choice",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_aftermath_truth_choice",
            speaker: .narrator,
            text: "You think of Leonidas's face. The nod.",
            choices: [
                DialogueChoice (
                    id: "truth_worth_yes",
                    text: "\"Yes.\"",
                    requires: nil,
                    leadsTo: "act3_aftermath_truth_end",
                    teaches: .spokeDirectTruthAtPersonalCost,
                    axisNote: "Integrity +2 — no qualification"
                ),
                DialogueChoice (
                    id: "truth_worth_idk",
                    text: "\"I don't know yet. Neither do you.\"",
                    requires: nil,
                    leadsTo: "act3_aftermath_truth_end",
                    teaches: nil,
                    axisNote: "Honest uncertainty"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_aftermath_truth_end",
            speaker: .demetrios,
            text: "He looks at you for a long moment. Then he turns and walks away down the corridor without another word.\n\nYou do not know if that is the end of it.\n\nYou suspect it is not.",
            choices: nil,
            nextNodeID: "act3_close_01",
            trigger: nil,
            teaches: nil
        ),

        // --- AFTERMATH: FALSE PROPHECY ---

        DialogueNode (
            id: "act3_aftermath_false",
            speaker: .narrator,
            text: "Demetrios finds you at the edge of the forecourt. He looks — relieved. It is a small expression, quickly managed, but you see it.\n\n\"He accepted the counsel?\"",
            choices: nil,
            nextNodeID: "act3_aftermath_false_02",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_aftermath_false_02",
            speaker: .narrator,
            text: "You think of Leonidas's face when he said the word patience. The way he tasted it.\n\n\"He listened,\" you say.",
            choices: nil,
            nextNodeID: "act3_aftermath_false_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_aftermath_false_03",
            speaker: .demetrios,
            text: "\"Good.\"\n\nHe nods — satisfied, already moving to the next calculation.\n\n\"The Athenian delegation will be pleased. The restoration proceeds.\"\n\nHe pauses.\n\n\"You did the right thing, Pythia. The larger harmony.\"\n\nHe goes.",
            choices: nil,
            nextNodeID: "act3_aftermath_false_end",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_aftermath_false_end",
            speaker: .narrator,
            text: "You stand in the forecourt alone.\n\nYou think about the vision. The narrow pass. The red cloaks.\n\nYou think about the word patience in Leonidas's mouth.",
            choices: nil,
            nextNodeID: "act3_close_01",
            trigger: nil,
            teaches: nil
        ),

        // --- AFTERMATH: RIDDLE ---

        DialogueNode (
            id: "act3_aftermath_riddle",
            speaker: .narrator,
            text: "Demetrios is in the corridor. He looks at your face and reads it — less clearly than after the truth, less easily than after the lie. Something in between, which makes him uncertain.",
            choices: nil,
            nextNodeID: "act3_aftermath_riddle_02",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_aftermath_riddle_02",
            speaker: .demetrios,
            text: "\"What did you give him?\"\n\nCareful. Not accusatory yet.",
            choices: nil,
            nextNodeID: "act3_aftermath_riddle_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_aftermath_riddle_03",
            speaker: .mara,
            text: "\"The Oracle's answer. The traditional form.\"\n\nYou meet his eyes.\n\n\"As you trained me.\"",
            choices: nil,
            nextNodeID: "act3_aftermath_riddle_04",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_aftermath_riddle_04",
            speaker: .demetrios,
            text: "He studies you.\n\n\"And how did he read it?\"\n\nYou see it then — that he does not know. That he cannot know. The riddle path gives neither of you certainty. Only Leonidas knows what he will do with what you gave him.",
            choices: nil,
            nextNodeID: "act3_aftermath_riddle_end",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_aftermath_riddle_end",
            speaker: .mara,
            text: "\"The way people read things,\" you say. \"The way that serves them.\"\n\nDemetrios looks at you for a long moment. Whatever he is looking for, he does not find it — or finds too much of it.\n\nHe nods, once, and goes.",
            choices: nil,
            nextNodeID: "act3_close_01",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - Act III Close

    static let actClose: [DialogueNode] = [
        DialogueNode (
            id: "act3_close_01",
            speaker: .narrator,
            text: "That night the adyton is quiet.\n\nYou sit on the tripod alone — no supplicant, no session, no laurel smoke. Just you and the flame and the silence of a room that has held ten thousand questions and answered all of them, and none of them.",
            choices: nil,
            nextNodeID: "act3_close_02",
            trigger: .enterLocation (.adyton),
            teaches: nil
        ),

        DialogueNode (
            id: "act3_close_02",
            speaker: .narrator,
            text: "You try to call the vision back. The pass. The cloaks. The aftermath.\n\nNothing comes.\n\nThe flame burns. The smoke rises. The god — if the god was ever here — offers nothing tonight.",
            choices: nil,
            nextNodeID: "act3_close_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_close_03",
            speaker: .narrator,
            text: "You sit for a long time.\n\nThen longer.\n\nAnd then you understand that the silence is not temporary. Something has changed — in the room, in you, in whatever thread connected you to the visions.\n\nYou do not know yet if it is broken or if it has simply moved somewhere you cannot reach.",
            choices: nil,
            nextNodeID: "act3_close_04",
            trigger: nil,
            teaches: .visionsHaveStopped
        ),

        DialogueNode (
            id: "act3_close_04",
            speaker: .narrator,
            text: "In the morning, there will be more delegations.\n\nThey will come from across Greece with their questions and their terror and their need for the god's voice.\n\nYou will have to answer them with something.\n\nYou do not yet know what.",
            choices: nil,
            nextNodeID: "act3_close_end",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act3_close_end",
            speaker: .narrator,
            text: "— ACT IV —\n\nTHE SILENCE",
            choices: nil,
            nextNodeID: "act4_open_01",
            trigger: .actTransition (toAct: 4),
            teaches: nil
        ),
    ]

    // MARK: - Vision Fragments: Leonidas
    //
    // Nine fragments — the most in the game, too many to hold comfortably.
    // The player must choose 3. The pressure of having to discard six of
    // nine fragments IS the design: this vision is overwhelming.
    //
    // Authoring note: dialogueOption is the oracle-voiced line that becomes
    // a dialogue choice in the three wording nodes:
    //   act3_leonidas_wording_truth   — how Mara speaks the truth
    //   act3_leonidas_wording_false   — how Mara speaks the lie
    //   act3_leonidas_wording_riddle  — which riddle Mara offers
    //
    // Each fragment maps to one choice in each of those three nodes.
    // The dialogueOption property stores the honest/direct reading.
    // The false and riddle variants are authored inline in the nodes above.

    static let leonidasFragments: [Fragment] = [
        Fragment (
            id: "leo_pass",
            type: .image (symbolName: "mountain.2.fill"),
            significance: "stone walls on either side — the world narrowed to one road",
            dialogueOption: "I saw a narrow pass in the mountains. Three hundred red cloaks. Arrows so thick they darkened the sky. I saw you fall. I saw the pass hold."
        ),
        Fragment (
            id: "leo_cloaks",
            type: .colour (hue: Color (red: 0.65, green: 0.12, blue: 0.12)),
            significance: "the colour of Sparta — three hundred times over",
            dialogueOption: "I saw three hundred red cloaks spread across a narrow place. I saw what they cost. I saw what they bought."
        ),
        Fragment (
            id: "leo_arrows",
            type: .sensation (text: "the sky\nbecoming solid"),
            significance: "so many they blocked the sun — someone said this was a mercy",
            dialogueOption: "The sky darkened. I understood what that meant before I understood the rest. You will not come back from the north. But what comes after you — does."
        ),
        Fragment (
            id: "leo_face",
            type: .image (symbolName: "person.fill"),
            significance: "a face that has already decided — before the march, before the question",
            dialogueOption: "I saw your face. It had already decided. Before the march. Before this room. The pass holds — because of what that face decided."
        ),
        Fragment (
            id: "leo_after",
            type: .word (text: "AFTER"),
            significance: "not the battle — what the battle made possible",
            dialogueOption: "I did not see the battle. I saw what comes after it. Greece holds. But you do not see it hold. You are already gone when it does."
        ),
        Fragment (
            id: "leo_ships",
            type: .image (symbolName: "water.waves"),
            significance: "the fleet, rallying — the pass had already done its work",
            dialogueOption: "I saw the fleet rallying. Ships that would have scattered — holding course. They held because the pass held first. Because you held it."
        ),
        Fragment (
            id: "leo_silence",
            type: .sensation (text: "three hundred\nvoices stopping\nat once"),
            significance: "the sound of a wall becoming a door",
            dialogueOption: "Three hundred voices, stopping at once. And then — the sound of a war that continues. Because they stopped."
        ),
        Fragment (
            id: "leo_fire",
            type: .colour (hue: Color (red: 0.90, green: 0.60, blue: 0.15)),
            significance: "not destruction — signal fire, carried ahead of the news",
            dialogueOption: "The signal fire carried the news ahead of the army. What the fire said was: it held. You will not see that fire. But it will carry your name."
        ),
        Fragment (
            id: "leo_word",
            type: .word (text: "HOLDS"),
            significance: "the pass. the line. the meaning of the sacrifice.",
            dialogueOption: "The word I kept hearing was holds. The pass holds. The line holds. Greece holds. You do not."
        ),
    ]
}
