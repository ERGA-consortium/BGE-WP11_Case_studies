#!/bin/bash

# ===== CONFIG =====
REF_DICT=/media/pc14c/1c655c55-710a-4390-aaa8-299a737eff89/JBL/crub/draft_chrom/chrom.soft.dict        # your reference dict file
PREFIX=cohort_                 # prefix of your VCF files (before scaffold name)
SUFFIX=.vcf.gz                 # suffix of your VCF files
OUT=cohort_all.vcf.gz          # final output VCF

# ===== BUILD FILE LIST IN REFERENCE ORDER =====
VCF_LIST=vcfs_in_order.list
> $VCF_LIST   # clear file

# Extract scaffold names from reference.dict and build file list
grep "^@SQ" $REF_DICT | awk '{print $2}' | cut -d: -f2 | while read scaffold; do
    VCF_FILE=${PREFIX}${scaffold}${SUFFIX}
    if [[ -f $VCF_FILE ]]; then
        echo $VCF_FILE >> $VCF_LIST
    else
        echo "⚠️  Warning: missing VCF for $scaffold ($VCF_FILE not found)" >&2
    fi
done

# ===== RUN GATK GatherVcfs =====
gatk GatherVcfs \
  $(awk '{print "-I "$1}' $VCF_LIST) \
  -O $OUT

echo "✅ Finished: merged VCF written to $OUT"

