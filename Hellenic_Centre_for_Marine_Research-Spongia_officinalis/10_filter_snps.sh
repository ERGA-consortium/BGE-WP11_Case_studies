#!/usr/bin/env bash

IN_VCF="results/gatk/joint/cohort.snps.vcf.gz"
REF="reference/genome.fna"

OUT_DIR="results/gatk/joint"
OUT_VCF="${OUT_DIR}/cohort.snps.filtered.vcf.gz"

mkdir -p "${OUT_DIR}" logs

echo "[$(date)] Filtering SNPs (hard filters)"

gatk VariantFiltration \
  -R "${REF}" \
  -V "${IN_VCF}" \
  -O "${OUT_VCF}" \
  --filter-name "QD2"              --filter-expression "QD < 2.0" \
  --filter-name "QUAL30"           --filter-expression "QUAL < 30.0" \
  --filter-name "SOR3"             --filter-expression "SOR > 3.0" \
  --filter-name "FS60"             --filter-expression "FS > 60.0" \
  --filter-name "MQ40"             --filter-expression "MQ < 40.0" \
  --filter-name "MQRankSum-12.5"   --filter-expression "MQRankSum < -12.5" \
  --filter-name "ReadPosRankSum-8" --filter-expression "ReadPosRankSum < -8.0" \
  >> "logs/filter_snps.log" 2>&1

echo "[$(date)] Filtered SNP VCF written to ${OUT_VCF}"
