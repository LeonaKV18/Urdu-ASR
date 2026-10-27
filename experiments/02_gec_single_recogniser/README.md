# 02 GEC on a single recogniser

An LLM corrects one recogniser's transcript at a time, for each of the three recognisers, on all 2,400 clips. The prompt tells it to fix only clear recognition errors and to leave correct text unchanged.

Each corrected transcript is scored against the same recogniser's baseline from [01](../01_baseline_transcription/README.md), so the change is the effect of the LLM alone.

## What is run

| Notebook | LLM | Examples in the prompt | Prompt |
|---|---|---|---|
| `gec_zero_shot_gemma.ipynb` | Gemma-3-12B | none | `gec_zero_shot` |
| `gec_zero_shot_gemini.ipynb` | Gemini | none | `gec_zero_shot` |
| `gec_few_shot_gemma.ipynb` | Gemma-3-12B | 5 | `gec_few_shot` |
| `gec_few_shot_gemini.ipynb` | Gemini | 5 | `gec_few_shot` |

All prompts are in [PROMPTS.md](../../PROMPTS.md). The five examples are FLEURS test and validation clips that are not among the 2,400 scored clips. Each recogniser's example shows its own transcript next to the reference.

## Files

| File | Contents |
|---|---|
| `results/corrections/<notebook>.csv` | One row per clip and condition: corrected text, status, LLM seconds, calls, input and output tokens |
| `results/scores/<notebook>_scores.csv` | WER, CER, S/D/I %, recogniser and LLM minutes, calls and tokens, for every subset, on all clips and on references with 3+ words, for the baseline and the corrected transcripts |
| `results/scores/<notebook>_vs_baseline.csv` | WER difference to each baseline recogniser with its paired-bootstrap 95% interval, lines changed, lines improved, lines worsened |
| `results/run_info/<notebook>.json` | LLM, settings, package versions, example clip IDs, LLM minutes |

## Machine

NVIDIA GeForce RTX 4080 (16 GB), Intel i9-13900K, 62 GiB RAM, Ubuntu 22.04.4 LTS. Gemma-3-12B runs in a llama.cpp server on this machine. Gemini is called through its API.

## Results

Not run yet.

## What it shows

Not run yet.
