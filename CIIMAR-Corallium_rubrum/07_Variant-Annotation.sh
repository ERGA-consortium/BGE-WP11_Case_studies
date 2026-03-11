#!/bin/bash

# ===== CONFIG =====
REF="/media/pc14c/1c655c55-710a-4390-aaa8-299a737eff89/JBL/crub/draft_chrom/chrom.soft.fa"
DICT="/media/pc14c/1c655c55-710a-4390-aaa8-299a737eff89/JBL/crub/draft_chrom/chrom.soft.dict"
SAMPLE_MAP="/media/pc14c/1c655c55-710a-4390-aaa8-299a737eff89/JBL/crub/trimmed/subset.list"
OUTDIR="/media/pc14c/1c655c55-710a-4390-aaa8-299a737eff89/JBL/crub/trimmed/bam/dedup/gvcf/joint_calling_subset"
THREADS=4       # threads per GATK run
MEM=16g         # memory per GATK run
NPROC=5         # how many chromosomes to run in parallel

gatk VariantAnnotator \
  -R $REF \
  -V joint_all_merged.vcf.gz \
  -O joint_all_merged.annotated.vcf \
  --annotation QualByDepth --annotation FisherStrand --annotation MappingQuality
