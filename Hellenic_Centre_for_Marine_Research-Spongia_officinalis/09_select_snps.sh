#!/usr/bin/env bash

IN_VCF="results/gatk/joint/cohort.gathered.vcf.gz"
REF="reference/genome.fna"

OUT_DIR="results/gatk/joint"
OUT_VCF="${OUT_DIR}/cohort.snps.vcf.gz"

mkdir -p "${OUT_DIR}" logs

echo "[$(date)] Selecting SNPs from cohort VCF"

gatk SelectVariants \
  -R "${REF}" \
  -V "${IN_VCF}" \
  --select-type-to-include SNP \
  -O "${OUT_VCF}" \
  >> "logs/select_snps.log" 2>&1

echo "[$(date)] SNP-only VCF written to ${OUT_VCF}"
