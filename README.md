# Urdu ASR with LLM error correction

We test whether large language models (LLMs) can correct the mistakes of Urdu speech recognisers, on one recogniser's output (GEC) or by combining several recognisers' outputs (fusion).

## Layout

```
Urdu-ASR/
├── README.md          this file: data, normaliser, metrics, models, machine, results
├── PROMPTS.md         every LLM prompt used, word for word
├── data/
│   ├── samples_FLEURS.csv                    the FLEURS clips: clip_id, subset, duration, reference
│   ├── samples_UrduSpeech_news_podcast.csv   the UrduSpeech clips, same columns
│   ├── transcripts/                          each recogniser's transcripts + all three side by side
│   ├── few_shot_examples.csv                 the five example clips used in few-shot prompts (never scored)
│   └── few_shot_candidates/                  the 40 clips the examples were picked from, with transcripts
└── experiments/
    ├── 01_baseline_transcription/   transcribe all clips with the 3 recognisers; transcribe candidate few-shot example clips
    ├── 02_gec_single_recogniser/    GEC: an LLM corrects one recogniser's transcript (Gemma, Gemini; zero-shot, few-shot)
    ├── 03_fusion_gec/               fusion GEC: an LLM sees all 3 transcripts and writes one corrected text
    ├── 04_fusion_rover/             fusion by word-level voting (ROVER), no LLM
    ├── 05_disagreement_gec/         fusion GEC: an LLM fills only the places where the recognisers disagree
    └── 06_three_step_gec/           GEC with pre-detection, chain-of-thought correction and verification (RLLM-CF)

```

Each experiment folder has one notebook per task, a `README.md` and a `results/` folder.

## Data

The samples files and all three recognisers' transcripts in `data/` are produced by `experiments/01_baseline_transcription`. Every later experiment reads them from `data/`, joining on `clip_id`.

| Dataset | Clips | Subsets | 
|---|---|---|
| FLEURS `ur_pk` | 1,200 (seed-42 shuffle of test + validation + train) | test, validation, train | 
| UrduSpeech news + podcast | 1,200 (first 1,200 in repository order) | benchmark (175, human-checked references), corpus (1,025, references written by Gemini)

Clips longer than 40 s are excluded for every recogniser. The dataset metadata lists none, and the samples files record the measured duration of every clip.

## Normaliser: `clean_urdu` v1 (frozen)

Applied to references and transcripts before every score. Steps:
1. Unicode NFC composition.
2. Remove diacritics and the tatweel stretch character.
3. Map Arabic letter forms to Urdu forms (e.g. ي → ی, ك → ک).
4. Replace punctuation with spaces.
5. Drop the standalone fragments اے, ای, ئے, ء, ے, او and collapse spaces.

## Metrics

| Metric | Definition |
|---|---|
| WER | (substitutions + deletions + insertions) ÷ reference words, summed over all clips in a subset |
| CER | The same on characters |
| S / D / I % | Substitutions, deletions, insertions as % of reference words (S + D + I = WER) |
| Time | Seconds per clip and total minutes, model loading excluded |
| Paired bootstrap 95% interval | 1,000 resamples of clips with replacement, seed 42 (Bisani & Ney, 2004). If the interval of WER(A) − WER(B) excludes 0, the difference is reliable. |

Each subset is scored on all clips and on clips whose reference has 3 or more words.

## Recognisers

| Recogniser | Model | Decoding |
|---|---|---|
| Whisper-large-v3 | `openai/whisper-large-v3` | Model defaults (greedy), language Urdu; long-form for clips over 30 s |
| Omnilingual | `omniASR_LLM_1B_v2`, `omnilingual-asr` 0.2.0 | Pipeline defaults |
| Indic Transcribe Core | `bodhan-ai/indic-transcribe-core` | Model defaults, one pass per clip (clips are not split) |

Word confidence is saved for Whisper only. Omnilingual's and Indic's transcribe functions return text only.

## Machine

| Experiment | Machine |
|---|---|
| 01 Baseline transcription | Kaggle, NVIDIA Tesla T4 (16 GB). Exact versions are in `results/run_info.json`. |
| 02 onwards | NVIDIA GeForce RTX 4080 (16 GB), driver 550.163.01, CUDA 12.4; Intel i9-13900K (24 cores, 32 threads); 62 GiB RAM; Ubuntu 22.04.4 LTS; Python 3.10.12. |

## Results

| Experiment | Headline | Details |
|---|---|---|
| 01 Baseline transcription | Indic Transcribe is best: 7.51% WER on the 175 human-checked UrduSpeech clips (Omnilingual 15.12%, Whisper 16.38%) | [README](experiments/01_baseline_transcription/README.md) |
| 02 GEC on single recogniser | Not run yet | [README](experiments/02_gec_single_recogniser/README.md) |
| 03 Fusion GEC | Not run yet | [README](experiments/03_fusion_gec/README.md) |
| 04 Fusion by ROVER voting | Not run yet | [README](experiments/04_fusion_rover/README.md) |
| 05 Disagreement GEC | Not run yet | [README](experiments/05_disagreement_gec/README.md) |
| 06 Three-step GEC | Not run yet | [README](experiments/06_three_step_gec/README.md) |
