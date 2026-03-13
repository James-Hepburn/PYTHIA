// ActIV.swift
// PYTHIA
//
// All dialogue nodes for Act IV — "The Silence".
// ~25 minutes of play. Covers:
//   · Opening — the adyton is empty, the visions are gone
//   · The first silent session — a supplicant Mara must face without Apollo
//   · Lyra in danger — consequences of prior choices surface
//   · Nikomedes returns — ally or neutral depending on Act II choice
//   · Demetrios — ally or enemy depending on Act III choice
//   · The final confrontation with herself — who is she without the god?
//   · Act IV close — leads into the Epilogue
//
// Node ID naming convention:
//   act4_[scene]_[beat]
//
// Connect: act3_close_end.nextNodeID = "act4_open_01"
// and pass ActI.nodes + ActII.nodes + ActIII.nodes + ActIV.nodes to NarrativeEngine.

import SwiftUI

enum ActIV {
    static var nodes: [DialogueNode] {
        opening + firstSilentSession + lyraInDanger + nikomedosReturns + demetriosReckoning + finalAdyton + actClose
    }

    // MARK: - Opening

    static let opening: [DialogueNode] = [
        DialogueNode (
            id: "act4_open_01",
            speaker: .narrator,
            text: "Three days after Leonidas leaves Delphi, word arrives that the Persian army has reached the coast of Thessaly.\n\nThe delegations do not slow. If anything they quicken — smaller city-states, merchants, frightened priests from other temples. Everyone wants the Oracle's voice now.",
            choices: nil,
            nextNodeID: "act4_open_02",
            trigger: .enterLocation (.templeForecourt),
            teaches: nil
        ),

        DialogueNode (
            id: "act4_open_02",
            speaker: .narrator,
            text: "You enter the adyton each morning and sit on the tripod and wait.\n\nThe laurel smoke rises. The flame holds. The silence holds too — vast and absolute, like a room from which all the furniture has been removed overnight.",
            choices: nil,
            nextNodeID: "act4_open_03",
            trigger: .enterLocation (.adyton),
            teaches: nil
        ),

        DialogueNode (
            id: "act4_open_03",
            speaker: .narrator,
            text: "On the fourth morning you stop waiting for it to end.\n\nThis is simply what the adyton is now. Stone and smoke and a flame that burns without speaking.",
            choices: nil,
            nextNodeID: "act4_open_04",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_open_04",
            speaker: .narrator,
            text: "Lyra brings water and watches your face.\n\n\"Are you all right?\"\n\nYou have been asked this question many times. You have never been less certain of the answer.",
            choices: [
                DialogueChoice (
                    id: "open_fine",
                    text: "\"Yes. Send in the first supplicant.\"",
                    requires: nil,
                    leadsTo: "act4_open_05",
                    teaches: nil,
                    axisNote: "Closes the conversation — Lyra notices"
                ),
                DialogueChoice (
                    id: "open_honest",
                    text: "\"I don't know. The visions have stopped.\"",
                    requires: nil,
                    leadsTo: "act4_open_lyra_honest",
                    teaches: .admittedSilenceToKeyPerson,
                    axisNote: "Integrity +2 — tells Lyra the truth"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_open_lyra_honest",
            speaker: .lyra,
            text: "She is very still for a moment.\n\n\"What will you do?\"\n\nNot panicked. Not accusing. Just — asking.",
            choices: [
                DialogueChoice (
                    id: "lyra_honest_idk",
                    text: "\"I don't know yet.\"",
                    requires: nil,
                    leadsTo: "act4_open_05",
                    teaches: nil,
                    axisNote: "Honest — Lyra stays close after this"
                ),
                DialogueChoice (
                    id: "lyra_honest_figure_out",
                    text: "\"Figure it out. The same way I figure out everything else.\"",
                    requires: nil,
                    leadsTo: "act4_open_05",
                    teaches: nil,
                    axisNote: "Mara's voice — Lyra believes her"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_open_05",
            speaker: .narrator,
            text: "The first supplicant of the day is a merchant from Corinth. He wants to know whether to send his ships north or south for the season.\n\nIt is, in the scale of what is happening, an almost absurdly small question.\n\nYou have nothing. The adyton offers nothing.\n\nYou must give him something.",
            choices: nil,
            nextNodeID: "act4_first_session_choice",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - First Silent Session

    static let firstSilentSession: [DialogueNode] = [
        DialogueNode (
            id: "act4_first_session_choice",
            speaker: .narrator,
            text: "The merchant waits. His hands are folded in supplication. He has paid the temple's fee. He expects the Oracle's voice.\n\nThe adyton is silent.",
            choices: [
                DialogueChoice (
                    id: "session_fabricate",
                    text: "\"The god shows calmer waters to the south this season. Go that way.\"",
                    requires: nil,
                    leadsTo: "act4_session_fabricate",
                    teaches: .fabricatedProphecyWithoutVision,
                    axisNote: "Integrity -2 — invented from nothing"
                ),
                DialogueChoice (
                    id: "session_refuse",
                    text: "\"The god is silent today. I cannot speak what I do not see. Return another time.\"",
                    requires: nil,
                    leadsTo: "act4_session_refuse",
                    teaches: .refusedToSpeakWithoutVision,
                    axisNote: "Integrity +1 — honest, but the temple will hear of it"
                ),
                DialogueChoice (
                    id: "session_knowledge",
                    text: "Draw on what you know — the Persian advance, the likely fleet movements, the season's winds. Speak from knowledge, not vision.",
                    requires: nil,
                    leadsTo: "act4_session_knowledge",
                    teaches: .drewOnAccumulatedKnowledge,
                    axisNote: "Integrity +1 — honest in its own way"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_session_fabricate",
            speaker: .narrator,
            text: "The merchant thanks you and goes, satisfied.\n\nYou sit in the silence afterward and think about the ships you sent south on a guess. You think about whether your guesses are better or worse than the visions were.\n\nYou do not know. That is what disturbs you most.",
            choices: nil,
            nextNodeID: "act4_lyra_danger_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_session_refuse",
            speaker: .narrator,
            text: "The merchant leaves — confused, then irritated, then quietly frightened in a way that has nothing to do with his ships.\n\nBy afternoon Demetrios knows. He comes to find you with a face that has decided something.",
            choices: nil,
            nextNodeID: "act4_demetrios_warning",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_demetrios_warning",
            speaker: .demetrios,
            text: "\"The Oracle does not turn supplicants away. That is not what this temple does.\"\n\nHe is not shouting. He is something past shouting — past the point where volume helps.\n\n\"Whatever is happening in the adyton, you manage it. Do you understand me?\"",
            choices: [
                DialogueChoice (
                    id: "demetrios_warn_yes",
                    text: "\"I understand.\"",
                    requires: nil,
                    leadsTo: "act4_lyra_danger_01",
                    teaches: .capitulatedToDemetriosWishes,
                    axisNote: "Integrity -2"
                ),
                DialogueChoice (
                    id: "demetrios_warn_push",
                    text: "\"And if there is nothing to manage? If the god has stopped speaking?\"",
                    requires: nil,
                    leadsTo: "act4_demetrios_warning_push",
                    teaches: .confrontedDemetriosDirectly,
                    axisNote: "Confrontation — shapes Act IV Demetrios path"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_demetrios_warning_push",
            speaker: .demetrios,
            text: "The silence between you is long enough to become its own kind of answer.\n\n\"Then you find another way to speak,\" he says finally. \"That is what the Oracle has always done.\"\n\nHe goes. You are not certain he is wrong.",
            choices: nil,
            nextNodeID: "act4_lyra_danger_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_session_knowledge",
            speaker: .narrator,
            text: "\"The northern sea-lanes will be disrupted this season,\" you tell him. \"The Persian fleet moves through those waters. The god counsels patience — southern routes, for now.\"\n\nIt is not prophecy. It is observation dressed in Oracle's language.\n\nHe thanks you and goes. You do not feel entirely clean about it, but you do not feel entirely wrong either.",
            choices: nil,
            nextNodeID: "act4_lyra_danger_01",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - Lyra in Danger

    static let lyraInDanger: [DialogueNode] = [
        DialogueNode (
            id: "act4_lyra_danger_01",
            speaker: .narrator,
            text: "On the second day of the silence, Lyra does not appear at her usual hour.\n\nYou find her in the corridor outside the Priests' Hall — pale, standing very still in the way of someone who has heard something they were not meant to hear.",
            choices: nil,
            nextNodeID: "act4_lyra_danger_02",
            trigger: .enterLocation (.priestsHall),
            teaches: .lyraInDanger
        ),

        DialogueNode (
            id: "act4_lyra_danger_02",
            speaker: .lyra,
            text: "\"Demetrios is meeting with the Athenian delegation again,\" she says quietly. \"They were talking about you.\"\n\nShe looks at you — frightened in a way she is trying not to show.\n\n\"They said the Oracle has become unreliable. That the temple may need to consider a replacement.\"",
            choices: nil,
            nextNodeID: "act4_lyra_danger_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_lyra_danger_03",
            speaker: .narrator,
            text: "You look at her — this girl who has brought you water every morning, who asked if you were all right and meant it.\n\nShe was not supposed to hear that conversation. Demetrios will know she did. In this temple, that is not a safe position to be in.",
            choices: nil,
            nextNodeID: "act4_lyra_danger_choice",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_lyra_danger_choice",
            speaker: .narrator,
            text: "You have very little power here. You have never had much. But you have some.",
            choices: [
                DialogueChoice (
                    id: "lyra_protect",
                    text: "\"Go to your family in the village. Tell them I sent you — that I need someone I trust outside the temple walls. Go tonight.\"",
                    requires: nil,
                    leadsTo: "act4_lyra_protected",
                    teaches: .savedLyra,
                    axisNote: "Saves Lyra — costs Mara her only ally inside the temple"
                ),
                DialogueChoice (
                    id: "lyra_keep_close",
                    text: "\"Stay close to me. Don't go anywhere alone. I'll handle Demetrios.\"",
                    requires: nil,
                    leadsTo: "act4_lyra_kept",
                    teaches: nil,
                    axisNote: "Keeps Lyra close — uncertain protection"
                ),
                DialogueChoice (
                    id: "lyra_nothing",
                    text: "\"Don't repeat what you heard. Go back to your duties and say nothing.\"",
                    requires: nil,
                    leadsTo: "act4_lyra_nothing",
                    teaches: .failedToSaveLyra,
                    axisNote: "Does nothing — Lyra is on her own"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_lyra_protected",
            speaker: .lyra,
            text: "She looks at you for a moment — then nods, quickly, before she can change her mind.\n\n\"Will you be all right?\"\n\nThe question again. This time you answer it differently.",
            choices: [
                DialogueChoice (
                    id: "lyra_protect_yes",
                    text: "\"Yes. Go.\"",
                    requires: nil,
                    leadsTo: "act4_niko_return_01",
                    teaches: nil,
                    axisNote: nil
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_lyra_kept",
            speaker: .lyra,
            text: "She nods. She stays.\n\nYou watch her go back to her duties and think about what Demetrios knows and what he will do with it, and how much protection your presence actually provides.",
            choices: nil,
            nextNodeID: "act4_niko_return_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_lyra_nothing",
            speaker: .narrator,
            text: "She nods and goes. She is careful, and quiet, and young, and you have just left her to manage something alone that she should not have to manage.\n\nYou tell yourself it is the safest choice. You are not sure you believe it.",
            choices: nil,
            nextNodeID: "act4_niko_return_01",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - Nikomedes Returns

    static let nikomedosReturns: [DialogueNode] = [
        DialogueNode (
            id: "act4_niko_return_01",
            speaker: .narrator,
            text: "On the third day of the silence, Nikomedes returns to Delphi.\n\nHe comes alone — no delegation, no ceremony. He asks to speak with the Pythia privately.",
            choices: nil,
            nextNodeID: "act4_niko_return_02",
            trigger: .enterLocation (.marasQuarters),
            teaches: .nikomedosReturned
        ),

        DialogueNode (
            id: "act4_niko_return_02",
            speaker: .nikomedes,
            text: "\"I've heard things.\"\n\nHe sits across from you — the same directness as before, the same careful watching.\n\n\"Word from the pass. Leonidas held it. Three days. Long enough for the fleet to manoeuvre.\"\n\nA pause.\n\n\"He's dead.\"",
            choices: nil,
            nextNodeID: "act4_niko_return_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_niko_return_03",
            speaker: .narrator,
            text: "You already knew. You saw it in the vision. But hearing it spoken aloud in a quiet room in Delphi three hundred miles from the pass — it lands differently.\n\nThe pass held. Greece holds.\n\nHe is dead.",
            choices: nil,
            nextNodeID: "act4_niko_return_04",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_niko_return_04",
            speaker: .nikomedes,
            text: "\"I also heard that the Oracle has gone quiet. That Demetrios is meeting with delegations privately — without you.\"\n\nHe looks at you steadily.\n\n\"I came to ask what you need.\"",
            choices: nil,
            nextNodeID: "act4_niko_return_choice",
            trigger: nil,
            teaches: nil
        ),

        // Branch based on whether Mara told Nikomedes the truth in Act II
        DialogueNode (
            id: "act4_niko_return_choice",
            speaker: .narrator,
            text: "You think about the night he stood in your doorway and asked whether Demetrios was telling you what to say.\n\nWhat you told him then shapes what he is now.",
            choices: [
                DialogueChoice (
                    id: "niko_trust_ask_help",
                    text: "\"I need someone outside this temple who knows what's actually happening. Can you move word to Athens — about what Demetrios has been doing?\"",
                    requires: .toldNikomedosTruth,
                    leadsTo: "act4_niko_ally",
                    teaches: .nikomedosWasAlly,
                    axisNote: "Requires Act II truth — opens the ally path"
                ),
                DialogueChoice (
                    id: "niko_neutral_nothing",
                    text: "\"I don't need anything. Thank you for coming.\"",
                    requires: nil,
                    leadsTo: "act4_niko_neutral",
                    teaches: .nikomedosWasNeutral,
                    axisNote: "Closes off the alliance — he leaves"
                ),
                DialogueChoice (
                    id: "niko_admit_silence",
                    text: "\"The visions have stopped. I've been speaking without the god for three days and I don't know how much longer I can do it.\"",
                    requires: nil,
                    leadsTo: "act4_niko_silence_admitted",
                    teaches: .admittedSilenceToKeyPerson,
                    axisNote: "Integrity +2 — honest with someone who can handle it"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_niko_ally",
            speaker: .nikomedes,
            text: "He is quiet for a moment — calculating, but not coldly.\n\n\"Athens has an interest in an Oracle that speaks truth rather than Demetrios's preferred version of it.\"\n\nHe stands.\n\n\"I'll move word. Give me two days.\"\n\nHe goes without ceremony — the way a man goes when he has already decided and action is the next thing.",
            choices: nil,
            nextNodeID: "act4_demetrios_reckoning_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_niko_neutral",
            speaker: .nikomedes,
            text: "He nods. He does not push.\n\n\"If that changes,\" he says, \"I'm staying in Delphi another two days.\"\n\nHe goes. He is not an ally. He is not an enemy. He is a careful man waiting to see which way this falls.",
            choices: nil,
            nextNodeID: "act4_demetrios_reckoning_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_niko_silence_admitted",
            speaker: .nikomedes,
            text: "He listens. He does not look surprised — more like a man whose theory has been confirmed for the second time.\n\n\"And what do you do,\" he says carefully, \"with a god who has stopped speaking?\"\n\nThe question is genuine. He actually wants to know.",
            choices: [
                DialogueChoice (
                    id: "silence_admitted_faith",
                    text: "\"Wait. He spoke before. He may speak again.\"",
                    requires: nil,
                    leadsTo: "act4_niko_silence_faith",
                    teaches: .maintainedFaithThroughSilence,
                    axisNote: "Faith +2"
                ),
                DialogueChoice (
                    id: "silence_admitted_alone",
                    text: "\"I think about whether he was ever speaking. Or whether it was always me.\"",
                    requires: nil,
                    leadsTo: "act4_niko_silence_philosopher",
                    teaches: .concludedVisionsWereHerOwn,
                    axisNote: "Faith -3 — crosses into disbelief"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_niko_silence_faith",
            speaker: .nikomedes,
            text: "He considers this for a long moment.\n\n\"That takes a particular kind of courage,\" he says. \"Waiting.\"\n\nHe stands. \"I'll be here two more days if you need anything.\"\n\nHe goes.",
            choices: nil,
            nextNodeID: "act4_demetrios_reckoning_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_niko_silence_philosopher",
            speaker: .nikomedes,
            text: "The silence between you is long.\n\n\"Then you were the Oracle all along,\" he says finally. Not unkindly. As a fact.\n\n\"That's either terrifying or liberating. Possibly both.\"\n\nHe stands. \"I'll be here two more days.\"\n\nHe goes, leaving you with a thought you cannot put back where it was.",
            choices: nil,
            nextNodeID: "act4_demetrios_reckoning_01",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - Demetrios Reckoning

    static let demetriosReckoning: [DialogueNode] = [
        DialogueNode (
            id: "act4_demetrios_reckoning_01",
            speaker: .narrator,
            text: "Demetrios comes to you on the fourth day.\n\nHe does not knock. He simply opens the door of your quarters and stands in it — and you understand from his face that something has been decided, and that he is here to tell you what it is.",
            choices: nil,
            nextNodeID: "act4_demetrios_reckoning_02",
            trigger: .enterLocation (.marasQuarters),
            teaches: nil
        ),

        DialogueNode (
            id: "act4_demetrios_reckoning_02",
            speaker: .demetrios,
            text: "\"The Athenian and Theban delegations have withdrawn their restoration commitments.\"\n\nHis voice is very even.\n\n\"Leonidas went to the pass. Word has reached Athens about what the Oracle told him. And now the delegations are asking what else the Oracle has been saying that they were not told about.\"",
            choices: nil,
            nextNodeID: "act4_demetrios_reckoning_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_demetrios_reckoning_03",
            speaker: .demetrios,
            text: "\"I have protected this temple for thirty years. I have managed difficult Pythias, difficult politics, difficult gods.\"\n\nHe looks at you.\n\n\"I do not know what to do with you.\"",
            choices: nil,
            nextNodeID: "act4_demetrios_reckoning_choice",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_demetrios_reckoning_choice",
            speaker: .narrator,
            text: "It is the most honest thing he has said to you.\n\nYou think about thirty years of managed truth. You think about Leonidas's face.",
            choices: [
                DialogueChoice (
                    id: "reckoning_confront",
                    text: "\"You managed the truth until the truth was too large to manage. That is what happened.\"",
                    requires: nil,
                    leadsTo: "act4_demetrios_confronted",
                    teaches: .demetriosWasEnemyInActIV,
                    axisNote: "Direct — Demetrios becomes an opponent"
                ),
                DialogueChoice (
                    id: "reckoning_offer",
                    text: "\"Help me find another way to serve this temple. One that doesn't require me to lie.\"",
                    requires: nil,
                    leadsTo: "act4_demetrios_offered",
                    teaches: .demetriosWasAllyInActIV,
                    axisNote: "Opens the ally path — only available if not already fully opposed"
                ),
                DialogueChoice (
                    id: "reckoning_silence",
                    text: "You say nothing. You look at him and wait.",
                    requires: nil,
                    leadsTo: "act4_demetrios_silence",
                    teaches: nil,
                    axisNote: "Silence — Demetrios makes his own decision"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_demetrios_confronted",
            speaker: .demetrios,
            text: "He looks at you for a long time.\n\n\"Yes,\" he says finally. \"That is what happened.\"\n\nHe does not apologise. He does not defend himself. He simply turns and walks out of your quarters, and you hear his footsteps recede down the corridor, and you do not know what he will do next.\n\nYou know what you will do.",
            choices: nil,
            nextNodeID: "act4_final_adyton_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_demetrios_offered",
            speaker: .demetrios,
            text: "He is very still.\n\nThe offer costs you something — you both know it. It requires you to acknowledge that the temple matters, that his decades of service were not simply corruption, that the question of how to speak truth in a world that cannot always hear it is genuinely hard.\n\n\"I will think about it,\" he says.\n\nHe goes. It is not a yes. But it is not a no.",
            choices: nil,
            nextNodeID: "act4_final_adyton_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_demetrios_silence",
            speaker: .demetrios,
            text: "The silence stretches.\n\nFinally he nods — to himself, it seems, more than to you.\n\n\"I'll make the arrangements,\" he says.\n\nYou do not know what arrangements. You do not ask. Some things are better not known until they are already done.",
            choices: nil,
            nextNodeID: "act4_final_adyton_01",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - The Final Adyton

    static let finalAdyton: [DialogueNode] = [
        DialogueNode (
            id: "act4_final_adyton_01",
            speaker: .narrator,
            text: "That night you go to the adyton alone.\n\nNo supplicant. No session. No Demetrios in the doorway. Just you and the flame and the question you have been avoiding since the silence began.",
            choices: nil,
            nextNodeID: "act4_final_adyton_02",
            trigger: .enterLocation (.adyton),
            teaches: nil
        ),

        DialogueNode (
            id: "act4_final_adyton_02",
            speaker: .narrator,
            text: "You sit on the tripod.\n\nYou close your eyes.\n\nYou try — one more time — to open yourself to whatever the adyton once gave you. The cold blue darkness. The fragments. The overwhelming sense of something larger moving through you.",
            choices: nil,
            nextNodeID: "act4_final_adyton_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_final_adyton_03",
            speaker: .narrator,
            text: "Nothing comes.\n\nThe flame burns. The smoke rises. The stone is cold beneath you.\n\nYou are alone in the adyton exactly as alone as a person can be.",
            choices: nil,
            nextNodeID: "act4_final_adyton_question",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_final_adyton_question",
            speaker: .narrator,
            text: "And then — not a vision, not Apollo, not anything you could call divine — a question surfaces from somewhere inside you that has been waiting since the first morning.\n\nWere the visions real?\n\nNot whether they were accurate. Not whether they were useful. Whether they came from something beyond you, or whether they were always — only — you.",
            choices: [
                DialogueChoice (
                    id: "final_faith",
                    text: "\"They were real. The silence doesn't change what came before.\"",
                    requires: nil,
                    leadsTo: "act4_final_faith",
                    teaches: .maintainedFaithThroughSilence,
                    axisNote: "Faith +2 — she keeps belief through the silence"
                ),
                DialogueChoice (
                    id: "final_philosopher",
                    text: "\"I don't know. And I think I have to be all right with not knowing.\"",
                    requires: nil,
                    leadsTo: "act4_final_uncertain",
                    teaches: .doubtedDivineOriginOfVision,
                    axisNote: "Faith -1 — honest uncertainty, neither faith nor disbelief"
                ),
                DialogueChoice (
                    id: "final_alone",
                    text: "\"They were mine. They were always mine. Apollo was the name I gave to the part of myself I was afraid to claim.\"",
                    requires: nil,
                    leadsTo: "act4_final_alone",
                    teaches: .concludedVisionsWereHerOwn,
                    axisNote: "Faith -3 — complete disbelief, philosopher path"
                ),
            ],
            nextNodeID: nil,
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_final_faith",
            speaker: .narrator,
            text: "You sit with that for a long time.\n\nThe silence does not break. The god does not return. The flame burns exactly as it burned yesterday and will burn tomorrow.\n\nBut you are still here. And you still believe something spoke through you — something true, something that mattered — and the silence does not erase that.\n\nYou are not the same as you were. But you know who you are.",
            choices: nil,
            nextNodeID: "act4_close_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_final_uncertain",
            speaker: .narrator,
            text: "You sit with the not-knowing.\n\nIt is uncomfortable in the way that honest things often are — no clean resolution, no divine confirmation, no clear answer to carry forward.\n\nBut there is something in naming it. In refusing to pretend certainty you do not have.\n\nYou are not sure what you are. But you are sure, at least, that you will not lie about it.",
            choices: nil,
            nextNodeID: "act4_close_01",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_final_alone",
            speaker: .narrator,
            text: "The thought settles into you like cold water.\n\nIt is terrifying. It is also — in some way you did not expect — a relief.\n\nIf the visions were yours, then so were the truths in them. And so was every choice you made about whether to speak them.\n\nYou were never an instrument. You were always the one who decided.\n\nYou sit in the adyton and look at the flame and feel the full weight of that.",
            choices: nil,
            nextNodeID: "act4_close_01",
            trigger: nil,
            teaches: nil
        ),
    ]

    // MARK: - Act IV Close

    static let actClose: [DialogueNode] = [
        DialogueNode (
            id: "act4_close_01",
            speaker: .narrator,
            text: "In the morning the temple is quieter than it has been.\n\nWord has spread — not of the silence exactly, but of something shifting. The kind of atmospheric change that empires feel before they change shape.",
            choices: nil,
            nextNodeID: "act4_close_02",
            trigger: .enterLocation (.templeForecourt),
            teaches: nil
        ),

        DialogueNode (
            id: "act4_close_02",
            speaker: .narrator,
            text: "You stand in the forecourt and watch the morning light on the stone columns and think about Leonidas, and Lyra, and Nikomedes, and Demetrios — and the farmer who asked about his harvest on your first day, whose name you never learned.\n\nAll of them carrying some version of what you gave them.",
            choices: nil,
            nextNodeID: "act4_close_03",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_close_03",
            speaker: .narrator,
            text: "There is one more thing to do.\n\nThere is always one more thing.",
            choices: nil,
            nextNodeID: "act4_close_end",
            trigger: nil,
            teaches: nil
        ),

        DialogueNode (
            id: "act4_close_end",
            speaker: .narrator,
            text: "— EPILOGUE —\n\nTHE FLAME",
            choices: nil,
            nextNodeID: nil,    // Links to epilogue_open_01
            trigger: .actTransition (toAct: 5),
            teaches: nil
        ),
    ]
}
