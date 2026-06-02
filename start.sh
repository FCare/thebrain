#!/bin/bash
#./llama.cpp/llama-server \
CUDA_VISIBLE_DEVICES=1 ./llama-cpp-turboquant/llama-server \
    -hf unsloth/Qwen3-VL-8B-Instruct-GGUF:UD-Q4_K_XL \
    --n-gpu-layers 99 \
    --jinja \
    --top-p 0.8 \
    --top-k 20 \
    --host 0.0.0.0 \
    --port 8000 \
    --temp 0.7 \
    --parallel 6\
    --min-p 0.0 \
    --flash-attn on \
    --presence-penalty 1.5 \
    --ctx-size 131072 \
    -ctk turbo4 \
    -ctv turbo4 \
    -fa 1 &

CUDA_VISIBLE_DEVICES=1 ./llama-cpp-turboquant/llama-server \
    -hf unsloth/Qwen3-4B-Thinking-2507-GGUF:UD-Q4_K_XL \
    --n-gpu-layers 99 \
    --jinja \
    --top-p 0.8 \
    --top-k 20 \
    --host 0.0.0.0 \
    --port 9000 \
    --temp 0.7 \
    --parallel 6\
    --min-p 0.0 \
    --flash-attn on \
    --presence-penalty 1.5 \
    --ctx-size 65536 \
    -ctk turbo4 \
    -ctv turbo4 \
    -fa 1 &

wait
