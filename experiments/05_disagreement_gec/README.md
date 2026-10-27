# 05 Disagreement GEC

The three transcripts are aligned word by word, as in ROVER. Words all three recognisers agree on are kept as written. Each place where they differ becomes a numbered blank listing what each recogniser wrote there. The LLM fills every blank: it can pick one of the options or write a different word. Prompt `disagreement_few_shot` in [PROMPTS.md](../../PROMPTS.md).

This limits the LLM to the places where the recognisers already doubt the text. Clips where the three transcripts fully agree make no LLM call. The result is scored against each of the three baselines from [01](../01_baseline_transcription/README.md).

## What is run

| Notebook | LLM |
|---|---|
| `disagreement_few_shot_gemma.ipynb` | Gemma-3-12B |
| `disagreement_few_shot_gemini.ipynb` | Gemini |

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
