#!/bin/bash

# ===== CONFIG =====
REF="/media/pc14c/1c655c55-710a-4390-aaa8-299a737eff89/JBL/crub/draft_chrom/chrom.soft.fa"
DICT="/media/pc14c/1c655c55-710a-4390-aaa8-299a737eff89/JBL/crub/draft_chrom/chrom.soft.dict"
SAMPLE_MAP="/media/pc14c/1c655c55-710a-4390-aaa8-299a737eff89/JBL/crub/trimmed/subset.list"
OUTDIR="/media/pc14c/1c655c55-710a-4390-aaa8-299a737eff89/JBL/crub/trimmed/bam/dedup/gvcf/joint_calling_subset/gvcfs/nodb"
THREADS=4       # threads per GATK run
MEM=16g         # memory per GATK run
NPROC=5         # how many chromosomes to run in parallel



gatk VariantFiltration \
  -R $REF \
  -V $OUTDIR/cohort_all.vcf.gz \
  --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0" \
  --filter-name "basic_snp_filter" \
  -O $OUTDIR/cohort_all.annotated.flt.vcf.gz




