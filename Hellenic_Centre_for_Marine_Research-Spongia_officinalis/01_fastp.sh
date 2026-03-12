#!/usr/bin/env bash

IN_DIR="data/raw"
OUT_DIR="results/trimmed"
THREADS=20
FASTP_BIN="fastp"

mkdir -p "${OUT_DIR}" logs

for R1 in "${IN_DIR}"/*_1.fq.gz; do
  R2="${R1/_1.fq.gz/_2.fq.gz}"
  base="$(basename "${R1}" _1.fq.gz)"

  echo "Processing ${base}"

  "${FASTP_BIN}" \
    --in1 "${R1}" \
    --in2 "${R2}" \
    --out1 "${OUT_DIR}/${base}_trimmed_1.fq.gz" \
    --out2 "${OUT_DIR}/${base}_trimmed_2.fq.gz" \
    --detect_adapter_for_pe \
    --thread "${THREADS}" \
    --html "${OUT_DIR}/${base}_fastp.html" \
    2> "logs/${base}.fastp.log"

done