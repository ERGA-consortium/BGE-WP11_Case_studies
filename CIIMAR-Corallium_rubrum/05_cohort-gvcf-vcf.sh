#!/bin/bash

# ===== CONFIG =====
REF="/media/pc14c/1c655c55-710a-4390-aaa8-299a737eff89/JBL/crub/draft_chrom/chrom.soft.fa"
DICT="/media/pc14c/1c655c55-710a-4390-aaa8-299a737eff89/JBL/crub/draft_chrom/chrom.soft.dict"
SAMPLE_MAP="/media/pc14c/1c655c55-710a-4390-aaa8-299a737eff89/JBL/crub/trimmed/subset.list"
OUTDIR="/media/pc14c/1c655c55-710a-4390-aaa8-299a737eff89/JBL/crub/trimmed/bam/dedup/gvcf/joint_calling_subset"
THREADS=4       # threads per GATK run
MEM=16g         # memory per GATK run
NPROC=5         # how many chromosomes to run in parallel

mkdir -p $OUTDIR/gvcfs $OUTDIR/vcfs

# Extract chromosome names from dict file
grep "^@SQ" $DICT | awk '{print $2}' | cut -d: -f2 > $OUTDIR/intervals.list

# Function for per-chromosome processing
run_chr () {
  CHR=$1
  echo "=== Processing $CHR ==="

  # Step 1: Combine gVCFs into cohort gVCF (per chromosome)
  gatk --java-options "-Xmx${MEM}" CombineGVCFs \
      -R $REF \
      -V $SAMPLE_MAP \
      -L $CHR \
      -O $OUTDIR/gvcfs/cohort_${CHR}.g.vcf.gz

  # Step 2: Genotype the cohort gVCF
  gatk --java-options "-Xmx${MEM}" GenotypeGVCFs \
      -R $REF \
      -V $OUTDIR/gvcfs/cohort_${CHR}.g.vcf.gz \
      -O $OUTDIR/vcfs/cohort_${CHR}.vcf.gz
}

export -f run_chr
export REF SAMPLE_MAP OUTDIR MEM THREADS

# Run chromosomes in parallel using GNU parallel
parallel -j $NPROC run_chr :::: $OUTDIR/intervals.list

# Step 3: Gather all per-chromosome cohort gVCFs
GVCF_LIST=$(ls $OUTDIR/gvcfs/cohort_*.g.vcf.gz | sort | sed 's/^/-I /' | tr '\n' ' ')
gatk GatherVcfs \
    $GVCF_LIST \
    -O $OUTDIR/cohort.g.vcf.gz

# Step 4: Gather all per-chromosome cohort VCFs
VCF_LIST=$(ls $OUTDIR/vcfs/cohort_*.vcf.gz | sort | sed 's/^/-I /' | tr '\n' ' ')
gatk GatherVcfs \
    $VCF_LIST \
    -O $OUTDIR/cohort.vcf.gz

echo "✅ Finished!"
echo "Final cohort gVCF: $OUTDIR/cohort.g.vcf.gz"
echo "Final cohort VCF : $OUTDIR/cohort.vcf.gz"
