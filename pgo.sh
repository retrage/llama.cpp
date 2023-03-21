#!/usr/bin/env bash

PGO_DIR=pgo-prof
PGO_RAW=${PGO_DIR}/llama-%p.profraw
PGO_DATA=${PGO_DIR}/llama.profdata
MODEL=./models/7B/ggml-model-q4_0.bin
PROMPT="Building a website can be done in 10 simple steps:"
N_TOKENS=128
N_ITER=5

mkdir -p ${PGO_DIR}

LLAMA_PGO=1 make -B

export LLVM_PROFILE_FILE="${PGO_RAW}"

for ((i = 0; i < ${N_ITER}; i++)); do
  ./main -m ${MODEL} -p "${PROMPT}" -n ${N_TOKENS}
done

llvm-profdata merge -output=${PGO_DATA} ${PGO_DIR}/llama-*.profraw

LLAMA_PGO=1 LLAMA_PGO_DATA=${PGO_DATA} make -B

./main -m ${MODEL} -p "${PROMPT}" -n ${N_TOKENS}
