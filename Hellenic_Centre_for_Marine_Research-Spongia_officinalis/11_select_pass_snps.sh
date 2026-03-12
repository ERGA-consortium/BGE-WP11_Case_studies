#!/usr/bin/env bash

IN_VCF="results/gatk/joint/cohort.snps.filtered.vcf.gz"   # output of VariantFiltration
REF="reference/genome.fna"

OUT_DIR="results/gatk/joint"
OUT_VCF="${OUT_DIR}/cohort.snps.PASS.vcf.gz"

mkdir -p "${OUT_DIR}" logs

echo "[$(date)] Selecting PASS SNPs"

gatk SelectVariants \
  -R "${REF}" \
  -V "${IN_VCF}" \
  --exclude-filtered true \
  --create-output-variant-index true \
  -O "${OUT_VCF}" \
  >> "logs/select_pass_snps.log" 2>&1

echo "[$(date)] PASS SNP VCF written to ${OUT_VCF}"
