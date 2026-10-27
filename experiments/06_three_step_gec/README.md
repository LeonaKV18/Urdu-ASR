# 06 Three-step GEC (RLLM-CF)

The three-stage method of Fang et al. (2025), with Gemma-3-12B, applied to each recogniser's transcript.

1. **Error pre-detection.** The LLM says whether the line has an error. If not, the line is kept.
2. **Chain-of-thought iterative correction.** The LLM locates the defective phrase, gives its pronunciation, lists candidates and selects one, and writes `[line] origin|changed`. If it changed the line, a separate call asks whether the corrected line is more likely than the original; if not, the correction is tried again with the rejected answers listed, up to three attempts.
3. **Answer verification.** The LLM checks that the answer has the required format and all four reasoning steps. If it fails, the original line is kept.

LLMs often change correct text, which makes the line worse than the input. Pre-detection and verification exist to stop that. The prompts are in [PROMPTS.md](../../PROMPTS.md). Temperature is 0.2, as in the paper.

Each corrected transcript is scored against the same recogniser's baseline from [01](../01_baseline_transcription/README.md).

## Files

| File | Contents |
|---|---|
| `three_step_gemma.ipynb` | Runs the three stages, scores |
| `results/corrections/<notebook>.csv` | One row per clip and condition: corrected text, status, LLM seconds, calls, input and output tokens |
| `results/scores/<notebook>_scores.csv` | WER, CER, S/D/I %, recogniser and LLM minutes, calls and tokens, for every subset, on all clips and on references with 3+ words, for the baseline and the corrected transcripts |
| `results/scores/<notebook>_vs_baseline.csv` | WER difference to each baseline recogniser with its paired-bootstrap 95% interval, lines changed, lines improved, lines worsened |
| `results/run_info/<notebook>.json` | LLM, settings, package versions, example clip IDs, LLM minutes |

`status` in the corrections file records where each line ended: `no_error_found`, `model_kept_original`, `not_confident`, `failed_verification`, `corrected`, `cut_off`, `unparseable` or `error`.

## Machine

NVIDIA GeForce RTX 4080 (16 GB), Intel i9-13900K, 62 GiB RAM, Ubuntu 22.04.4 LTS. Gemma-3-12B runs in a llama.cpp server on this machine.

## Results

Not run yet.

## What it shows

Not run yet.
