# 05 Disagreement GEC

The three transcripts are aligned word by word, as in ROVER. Words all three recognisers agree on are kept as written. Each place where they differ becomes a numbered blank listing what each recogniser wrote there. The LLM fills every blank: it can pick one of the options or write a different word. Prompt `disagreement_few_shot` in [PROMPTS.md](../../PROMPTS.md).

This limits the LLM to the places where the recognisers already doubt the text. Clips where the three transcripts fully agree make no LLM call. The result is scored against each of the three baselines from [01](../01_baseline_transcription/README.md).

## What is run

| Notebook | LLM |
|---|---|
| `disagreement_few_shot_gemma.ipynb` | Gemma-3-12B |
| `disagreement_few_shot_gemini.ipynb` | Gemini |
| `disagreement_few_shot_gemma_v2.ipynb` | Gemma-3-12B, v2 (see below) |

### v2: the LLM answers only the blanks

In `disagreement_few_shot_gemma.ipynb` the LLM writes the whole line back. On long clips Gemma often wrote only its answers to the blanks and left out the agreed words between them, so deletions rose sharply (16.6% on the UrduSpeech corpus). In v2 (prompt `disagreement_fill_few_shot`) the LLM outputs one numbered answer per blank and the notebook rebuilds the line, so agreed words are always kept. A blank the LLM does not answer gets the ROVER vote for that blank. The corrections file also saves the raw reply, the number of blanks and the number answered. v2 is scored against the three baselines and against ROVER from [04](../04_fusion_rover/README.md).

## Files

| File | Contents |
|---|---|
| `results/corrections/<notebook>.csv` | One row per clip and condition: corrected text, status, LLM seconds, calls, input and output tokens |
| `results/scores/<notebook>_scores.csv` | WER, CER, S/D/I %, recogniser and LLM minutes, calls and tokens, for every subset, on all clips and on references with 3+ words, for the baseline and the corrected transcripts |
| `results/scores/<notebook>_vs_baseline.csv` | WER difference to each baseline recogniser with its paired-bootstrap 95% interval, lines changed, lines improved, lines worsened |
| `results/run_info/<notebook>.json` | LLM, settings, package versions, example clip IDs, LLM minutes |

## Machine

NVIDIA GeForce RTX 4080 (16 GB), Intel i9-13900K, 62 GiB RAM, Ubuntu 22.04.4 LTS.

## Results

Not run yet.

## What it shows

Not run yet.
