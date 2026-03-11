#!/usr/bin/env bash
set -euo pipefail

# ===========================
# ARGUMENTS
# ===========================
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 SAMPLE"
  exit 1
fi

SAMPLE="$1"

# ===========================
# CONFIGURATION
# ===========================
REF="/media/pc14c/1c655c55-710a-4390-aaa8-299a737eff89/JBL/crub/draft_chrom/chrom.soft.fa"                # Reference FASTA
BAM="bam/dedup/${SAMPLE}.withRG.dedup.bam"              # BAM for this sample
SCATTER=6                                 # Number of intervals
THREADS=2                                  # Threads per HaplotypeCaller job
OUTDIR="bam/dedup/gvcf/intervals"			   # Output directory intervals GVCF
OUTDIR2="bam/dedup/gvcf"			   # Output directory final gvcf
INTERVAL_DIR="intervals"         # Interval directory
FINAL_GVCF="${SAMPLE}.g.vcf.gz"
#mkdir -p "$INTERVAL_DIR"


# ===========================
# SKIP IF FINAL OUTPUT EXISTS
# ===========================
if [[ -f "$OUTDIR2/$FINAL_GVCF" ]]; then
  echo "[INFO] Final GVCF for $SAMPLE already exists. Skipping."
  exit 0
fi

echo "[INFO] Processing SAMPLE=$SAMPLE"

# ===========================
# 1. SPLIT INTERVALS (only if not done yet)
# ===========================
if [[ ! -f "$INTERVAL_DIR"/0001-scattered.interval_list ]]; then
  echo "[INFO] Splitting genome into $SCATTER intervals..."
  gatk SplitIntervals \
    -R "$REF" \
    --scatter-count 6 \
    -O "$INTERVAL_DIR"
else
  echo "[INFO] Interval lists already exist. Skipping splitting."
fi

# ===========================
# 2. RUN HAPLOTYPECALLER IN PARALLEL
# ===========================
echo "[INFO] Running HaplotypeCaller on each interval..."
ls "$INTERVAL_DIR"/*.interval_list | parallel -j "$SCATTER" "
  OUTFILE=$OUTDIR/${SAMPLE}.{#}.g.vcf.gz
  if [[ ! -f \$OUTFILE ]]; then
    gatk HaplotypeCaller \
      -R $REF \
      -I $BAM \
      -ERC GVCF \
      --native-pair-hmm-threads $THREADS \
      -L {} \
      -O \$OUTFILE
  else
    echo '[INFO] Interval output '\$OUTFILE' already exists. Skipping.'
  fi
"

# ===========================
# 3. MERGE INTERVAL GVCFs
# ===========================
echo "[INFO] Merging interval GVCFs..."
#MERGE_INPUTS=$(printf " -I %s" $OUTDIR/${SAMPLE}.g.vcf.gz.*)

MERGE_INPUTS=$(printf " -I %s" $(ls "$OUTDIR"/"$SAMPLE".[0-9]*.g.vcf.gz | sort -t. -k2,2n))
gatk MergeVcfs \
  $MERGE_INPUTS \
  -O $OUTDIR2/${SAMPLE}.g.vcf.gz

# ===========================
# 4. CLEAN UP
# ===========================
rm $OUTDIR/${SAMPLE}.[0-9]*.g.vcf.gz.* || true

echo "[INFO] Done: $FINAL_GVCF"

