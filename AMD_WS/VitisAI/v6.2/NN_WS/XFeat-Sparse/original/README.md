# Original XFeat-Sparse CPU Pipeline

This workspace keeps the official XFeat sparse matching flow for reference
execution and `.npy` vector capture only. It is not compiled for NPU.

## Source

- Official repository: `https://github.com/verlab/accelerated_features`
- Weights:
  - `weights/xfeat.pt`
  - `weights/xfeat-lighterglue.pt`

## Run

```bash
bash 01_setup.bash
bash 03_run_host.bash
```

Outputs:

- `results/original_host/matches_lighterglue.png`
- `results/original_host/summary.json`
- `test_vectors/xfeat_*.npy`
- `test_vectors/lighterglue_*.npy`

The generated `.npy` vectors are consumed by `../xfeat` and
`../Lighter_Glue`.

## Boundary

The official path runs:

```text
image pair -> XFeat sparse extraction -> LighterGlue -> matches
```

For NPU bring-up this full path is intentionally not exported as one model
because it contains dynamic keypoint selection and variable-length match output.

## Verified Local Result

The generated smoke pair produced:

- `top_k`: 128
- sparse features: 128 / 128
- LighterGlue matches: 56
- xFeat model input shape: `1 x 3 x 480 x 640`
