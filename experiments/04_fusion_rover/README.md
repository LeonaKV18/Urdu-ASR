# 04 Fusion by ROVER voting

ROVER (Recogniser Output Voting Error Reduction) combines the three transcripts without an LLM. They are aligned word by word. At each position the word written by most recognisers is kept; if most wrote nothing, the position is dropped. Ties go to the recogniser with the lowest baseline WER: Indic Transcribe, then Omnilingual, then Whisper.

It shows how much of the gain from fusion comes from voting alone, which the LLM fusion in [03](../03_fusion_gec/README.md) has to beat.

## Files

| File | Contents |
|---|---|
| `rover.ipynb` | Aligns, votes, scores |
| `results/corrections/rover.csv` | Voted text per clip |
| `results/scores/rover_scores.csv` | WER, CER, S/D/I %, recogniser minutes and voting time, for every subset, on all clips and on references with 3+ words |
| `results/scores/rover_vs_baseline.csv` | WER difference to each baseline recogniser with its paired-bootstrap 95% interval, lines changed, improved, worsened |
| `results/run_info/rover.json` | Settings and package versions |

## Machine

NVIDIA GeForce RTX 4080 (16 GB), Intel i9-13900K, 62 GiB RAM, Ubuntu 22.04.4 LTS. The voting runs on the CPU.

## Results

Not run yet.

## What it shows

Not run yet.
