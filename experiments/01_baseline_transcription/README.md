# 01 Baseline transcription

Transcribes the same 2,400 clips with three recognisers and scores each against the human or Gemini references. These scores are the baseline that every correction experiment is compared with, and the saved transcripts are the input those experiments read.

## What is done

- **Clips:** 1,200 FLEURS (`ur_pk`; test, validation and train, shuffled with seed 42) and 1,200 UrduSpeech news + podcast (175 benchmark clips with human-checked references, then 1,025 corpus clips with Gemini-written references). No clip is over 40 s, so all three recognisers transcribe the same 2,400 clips.
- **Recognisers:**
  - Whisper-large-v3, language Urdu, greedy decoding.
  - Omnilingual LLM 1B v2 (`omniASR_LLM_1B_v2`), pipeline defaults. It decodes with a beam of 5 and returns only the best text.
  - Indic Transcribe Core, language `ur`, one pass per clip.
- **Audio:** 16 kHz mono, saved once and read by all three recognisers.
- **Whisper word confidence:** saved for clips up to 30 s. A word's probability is the product of its tokens' probabilities. Omnilingual and Indic Transcribe return text only.
- **Scoring:** `clean_urdu` v1 on reference and transcript, then corpus-level WER, CER and the substitution / deletion / insertion split. A paired bootstrap (1,000 resamples, seed 42) gives a 95% interval for the WER difference between each pair of recognisers.
- **FLEURS subsets:** test + validation is reported separately from train, because Omnilingual was trained on FLEURS.

## Files

| File | Contents |
|---|---|
| `baseline_transcription.ipynb` | Builds the samples files, transcribes, scores |
| `few_shot_examples.ipynb` | Transcribes 40 FLEURS test and validation clips that are not among the scored clips, with the three recognisers, so the five few-shot example clips can be chosen from them. Writes `data/few_shot_candidates/` |
| `data/samples_FLEURS.csv`, `data/samples_UrduSpeech_news_podcast.csv` | One row per clip: ID, dataset, subset, category, duration, reference, included |
| `data/transcripts/<recogniser>_transcripts.csv` | Transcript, seconds, status, decoding settings and word confidence per clip |
| `data/transcripts/all_recognisers_by_clip.csv` | All three transcripts side by side, raw and normalised, with per-clip WER and CER |
| `results/scores/recogniser_scores.csv` | WER, CER, S/D/I %, time per subset. A second set of rows leaves out the 26 UrduSpeech corpus clips whose reference has fewer than 3 words. |
| `results/scores/paired_bootstrap.csv` | WER difference between each pair of recognisers with its 95% interval |
| `results/run_info.json` | Machine, package versions, models, decoding settings, elapsed time |

## Results

Kaggle, Tesla T4.

**WER % (CER % in brackets)**

| Subset | Clips | Whisper-large-v3 | Omnilingual LLM 1B v2 | Indic Transcribe Core |
|---|---|---|---|---|
| UrduSpeech benchmark | 175 | 16.38 (7.30) | 15.12 (7.51) | **7.51 (3.01)** |
| UrduSpeech corpus | 1,025 | 22.90 (12.57) | 14.76 (7.57) | **9.71 (5.07)** |
| FLEURS test + validation | 251 | 20.64 (7.41) | 15.24 (5.08) | **12.57 (4.71)** |
| FLEURS train | 949 | 18.72 (7.08) | **6.58 (2.36)** | 12.89 (5.66) |

**Error split, % of reference words (substitutions / deletions / insertions)**

| Subset | Whisper-large-v3 | Omnilingual LLM 1B v2 | Indic Transcribe Core |
|---|---|---|---|
| UrduSpeech benchmark | 12.03 / 3.07 / 1.27 | 9.60 / 4.02 / 1.51 | 5.13 / 0.98 / 1.40 |
| UrduSpeech corpus | 13.67 / 5.02 / 4.22 | 9.04 / 3.99 / 1.73 | 5.60 / 1.83 / 2.27 |
| FLEURS test + validation | 16.05 / 1.89 / 2.70 | 11.21 / 2.05 / 1.98 | 8.44 / 1.42 / 2.71 |
| FLEURS train | 14.42 / 1.57 / 2.72 | 4.69 / 0.90 / 0.98 | 8.75 / 1.07 / 3.07 |

**Time** (seconds per clip / total minutes, 1,200 clips each)

| Dataset | Whisper-large-v3 | Omnilingual LLM 1B v2 | Indic Transcribe Core |
|---|---|---|---|
| FLEURS | 2.30 s / 46.0 min | 2.40 s / 48.0 min | 2.00 s / 40.0 min |
| UrduSpeech | 3.89 s / 77.9 min | 4.92 s / 98.5 min | 3.38 s / 67.6 min |
| Both datasets | 3.10 s / 123.9 min | 3.66 s / 146.5 min | 2.69 s / 107.6 min |

## What it shows

- Indic Transcribe is the most accurate recogniser on UrduSpeech. Its WER difference to each other recogniser has a 95% interval that excludes 0. On the benchmark it is 7.6 points below Omnilingual (interval 4.5 to 12.1) and 8.9 below Whisper (7.4 to 10.6).
- On the benchmark, Whisper and Omnilingual are not reliably different (interval −2.2 to 4.1). On the corpus, Omnilingual is lower.
- Omnilingual was trained on FLEURS train: 6.58% on train against 15.24% on test + validation. Indic Transcribe's train score (12.89%) is not lower than its test + validation score (12.57%), so there is no sign of the same effect. Its training data is not named.
- Indic Transcribe is also the fastest of the three, at 2.69 s per clip.
- Omnilingual and Whisper make mostly substitution errors; Whisper has the highest insertion rate on the corpus (4.22%).
