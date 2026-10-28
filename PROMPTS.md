# Prompts

Every prompt sent to an LLM in this project, word for word. `{...}` marks a value the notebook fills in.

## Settings shared by all prompts

| Setting | Gemma-3-12B | Gemini |
|---|---|---|
| Interface | llama.cpp server, `/v1/chat/completions` | Gemini API |
| Temperature | 0 (three-step method: 0.2) | 0 (the three-step method is not run on Gemini) |
| Output token limit | 512 (three-step stage 2: 1,024; yes/no answers: 16) | 512 |
| Message | One user message holding the whole prompt | Same |

- Diacritics and punctuation are removed from every transcript and reference before it goes into a prompt. Scoring applies `clean_urdu` v1 to the reply.
- Gemini is called with thinking switched off (thinking budget 0), so every output token is the answer.
- The first non-empty line of the reply is used, with a leading `Corrected:` removed. An empty reply, a reply cut off at the token limit, or an error keeps the input transcript unchanged and is recorded in the `status` column.

## Few-shot examples

Five FLEURS test and validation clips that are not among the 2,400 scored clips, so they are never scored. FLEURS test and validation clips with 3 to 25 words were put in seed-42 shuffled order and the first 40 were transcribed by the three recognisers (`experiments/01_baseline_transcription/few_shot_examples.ipynb`). The five examples are the first of these 40 where every recogniser makes at least one error. FLEURS references are written by people. Train clips are not used because Omnilingual was trained on them. All notebooks and both datasets use the same five clips.

Each recogniser's own transcript goes on the left of its example. The right side is the reference.

---

## P1. `gec_zero_shot`: correct one transcript, no examples

Used in: 02 (Gemma and Gemini, run once per recogniser).

```
You are a strict Urdu ASR post-editor. Correct ONLY clear recognition errors in the line: wrong or garbled words, wrongly split/merged words, obvious spelling mistakes.
Rules:
- Do NOT translate.
- Do NOT add, remove, reorder or rephrase words that are already correct.
- Do NOT add punctuation, diacritics or any explanation.
- If the line is already correct, return it unchanged.
Output ONLY the corrected Urdu line, nothing else.

Line: {transcript}
Corrected:
```

## P2. `gec_few_shot`: correct one transcript, five examples

Used in: 02 (Gemma and Gemini, run once per recogniser).

```
You are a strict Urdu ASR post-editor. Correct ONLY clear recognition errors in the line: wrong or garbled words, wrongly split/merged words, obvious spelling mistakes.
Rules:
- Do NOT translate.
- Do NOT add, remove, reorder or rephrase words that are already correct.
- Do NOT add punctuation, diacritics or any explanation.
- If the line is already correct, return it unchanged.
Output ONLY the corrected Urdu line, nothing else.

Here are 5 examples:

Noisy: {example_1_recogniser_transcript}
Corrected: {example_1_reference}

Noisy: {example_2_recogniser_transcript}
Corrected: {example_2_reference}

(examples 3, 4 and 5 in the same form)

Now correct this line. Output only the corrected line.
Noisy: {transcript}
Corrected:
```

## P3. `fusion_few_shot`: three transcripts in, one corrected line out

Used in: 03 (Gemma and Gemini).

```
You are a strict Urdu ASR post-editor. You are given the same audio transcribed by three different speech recognisers: Whisper, Omni and Indic. They make different mistakes. Write the single correct Urdu line.
Rules:
- Use the three transcripts together: where they agree the words are usually right; where they differ, choose the reading that makes sense in the sentence, or fix it if none is right.
- Do NOT translate.
- Do NOT add words that none of the transcripts support.
- Do NOT add punctuation, diacritics or any explanation.
Output ONLY the corrected Urdu line, nothing else.

Here are 5 examples:

Whisper: {example_1_whisper}
Omni: {example_1_omni}
Indic: {example_1_indic}
Corrected: {example_1_reference}

(examples 2 to 5 in the same form)

Now correct this line. Output only the corrected line.
Whisper: {whisper_transcript}
Omni: {omni_transcript}
Indic: {indic_transcript}
Corrected:
```

## P4. `disagreement_few_shot`: fill in only the places where the recognisers differ

Used in: 05 (Gemma and Gemini).

The three transcripts are aligned word by word (the same alignment as ROVER). Where all three agree, the word stays as written. Where they differ, the notebook puts a numbered blank `[1]`, `[2]`, … in the line and lists what each recogniser wrote there. Neighbouring differing positions form one blank.

```
You are a strict Urdu ASR post-editor. Three speech recognisers transcribed the same audio and disagreed in some places. The words they agree on are kept. Each place where they disagree is a numbered blank in square brackets, with the options the recognisers wrote.
Rules:
- Fill every blank. You may pick one of its options, or write a different word or phrase if none of them fits. An option "(nothing)" means a recogniser wrote nothing there; you may leave the blank empty.
- Do NOT change any word outside the blanks.
- Do NOT translate.
- Do NOT add punctuation, diacritics or any explanation.
Output ONLY the full Urdu line with the blanks filled, nothing else.

Here are 5 examples:

Line: {example_1_line_with_blanks}
Blank 1 - Whisper: {x} | Omni: {y} | Indic: {z}
Blank 2 - Whisper: {x} | Omni: {y} | Indic: {z}
Corrected: {example_1_reference}

(examples 2 to 5 in the same form)

Now correct this line. Output only the corrected line.
Line: {line_with_blanks}
Blank 1 - Whisper: {x} | Omni: {y} | Indic: {z}
Blank 2 - Whisper: {x} | Omni: {y} | Indic: {z}
Corrected:
```

Where the three transcripts fully agree, no LLM call is made and the line is kept.

---

## P5. Three-step method

Used in: 06 (Gemma only), on one recogniser's transcript at a time. Temperature 0.2. The method is RLLM-CF ([Fang et al., arXiv:2505.24347](https://arxiv.org/abs/2505.24347)).

1. **Stage 1, error pre-detection.** One call per line. If no error is found the line is kept and nothing else is called.
2. **Stage 2, chain-of-thought iterative correction.** The model works through four sub-tasks (locate the defective phrase, give its pronunciation, list candidates by pronunciation, select a candidate using the context) and gives the result as `Result:<flag>[sentence]` with the flag `origin` or `changed`. A separate confidence call asks whether the corrected line is more likely right than the input. If not, the correction is tried again, telling the model which answers were already rejected. At most three attempts.
3. **Stage 3, answer verification.** One call checks (a) the output is in the required format and (b) every reasoning step was completed. If both pass, the corrected line is kept. Otherwise the input line is kept.

The Stage 2 prompt includes three worked examples of the reasoning steps (Input, Inference, the four steps, Result). They are written by hand from transcripts of clips outside the 2,400 scored clips: two corrections of letters that sound alike and one sentence that needs no change. They are saved in `data/three_step_worked_examples.txt`, which the notebook reads. The Stage 2 prompt is followed by the worked examples, then (from the second attempt) the rejected answers, then `Input: {transcript}`. The other three prompts below end with the line shown.

### P5a. `three_step_detect` (Stage 1)

An answer that starts with OK keeps the line. Any other answer sends it to Stage 2.

```
You will be given a short Urdu sentence produced by speech recognition. Usually errors are due to homophones (words that sound alike) and similar recognition mistakes.
Determine whether the sentence has errors that need correcting: wrong or garbled words, wrongly split or merged words, obvious spelling mistakes.
Answer with exactly one word: ERROR if the sentence has an error, or OK if it does not.

Sentence: {transcript}
Answer:
```

### P5b. `three_step_correct` (Stage 2)

```
You will be provided with short Urdu sentences after speech recognition, and your task is to correct these short sentences to a standard correct recognition result without typos and language errors. Usually errors are due to homophones and so on.
Determine whether a sentence has errors; if not, output the original result directly; otherwise, follow the subtasks below for derivation.

Subtasks:
1. Locating: split sentences and locate the position of the defective phrase in the sentence.
2. Pronunciation: give the pronunciation of the defective phrase.
3. Candidates: give multiple candidates according to their pronunciation.
4. Selection: select the appropriate candidates combined with the context.

Think many times and be sure of the outcome.
For the corrected sentence, you need to continue to determine whether there is a language problem. If you do not have confidence about the correction, then give up the correction. You can correct the sentence up to three times.
Do NOT translate.
The final output needs to be wrapped in a [] and with a flag (origin or changed) to mark whether the change is made, in the form:
Result:<flag>[sentence]

Three examples of the reasoning steps:

{contents of data/three_step_worked_examples.txt}

Answers already tried and rejected (do not repeat them):
{rejected_answers}   (this block is left out on the first attempt)

Input: {transcript}
```

### P5c. `three_step_confidence` (Stage 2 confidence check)

```
An Urdu speech-recognition sentence was corrected.

Original: {transcript}
Corrected: {candidate}

Which is more likely to be what the speaker actually said? Answer with exactly one word: CORRECTED if you are more confident in the corrected sentence, or ORIGINAL if you are more confident in the original.
Answer:
```

### P5d. `three_step_verify` (Stage 3)

```
You are checking the answer of an Urdu speech-recognition correction step.

Original: {transcript}
Model answer:
{full_stage_2_answer}

Check two things:
(1) Format: the last line is in the form Result:<flag>[sentence], where the flag is origin or changed.
(2) Reasoning: the answer completed all four steps (locating, pronunciation, candidates, selection) and the selection follows from the candidates.

Answer with exactly one word: PASS if both hold, or FAIL if either does not.
Answer:
```
