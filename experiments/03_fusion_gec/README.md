# 03 Fusion GEC

An LLM receives the Whisper, Omnilingual and Indic Transcribe transcripts of a clip together, with five examples, and writes one corrected line. Prompt `fusion_few_shot` in [PROMPTS.md](../../PROMPTS.md).

The fused line is scored against each of the three baselines from [01](../01_baseline_transcription/README.md).

## What is run

| Notebook | LLM |
|---|---|
| `fusion_few_shot_gemma.ipynb` | Gemma-3-12B |
| `fusion_few_shot_gemini.ipynb` | Gemini |

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
