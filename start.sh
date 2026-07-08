#!/bin/bash
CUDA_VISIBLE_DEVICES=1 ./llama.cpp/llama-server \
    -m /root/.cache/gemma-4-12B-it-qat-UD-Q4_K_XL.gguf \
    --alias gemma-4-12b-it \
    --mmproj /root/.cache/mmproj-F16.gguf \
    --host 0.0.0.0 \
    --port 8000 \
    --n-gpu-layers 99 \
    --jinja \
    --ctx-size 131072 \
    --temp 1.0 \
    --top-p 0.95 \
    --top-k 64 \
    --parallel 1 \
    --reasoning on \
    --reasoning-budget 1700 &

wait
