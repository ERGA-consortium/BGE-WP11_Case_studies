#!/usr/bin/env bash

# Where per-interval GVCFs are (from Step 05a)
GVCF_DIR="results/gatk/gvcf_intervals"

# Where BAMs are (used only to get sample names)
BAM_DIR="results/bam_dedup"   # must match the BAMs used for HaplotypeCaller

# Ordered intervals list used in HaplotypeCaller
INTERVALS_LIST="intervals/genome_6Mb.list"

# Output directory for per-sample merged GVCFs
OUT_DIR="results/gatk/gvcf_merged"

MAX_JOBS=35
JAVA_XMX="6g"

mkdir -p "${OUT_DIR}" logs

job_count=0
for BAM in "${BAM_DIR}"/*.bam; do
  SAMPLE=$(basename "${BAM}" .bam)

  (
    LIST="${OUT_DIR}/${SAMPLE}.inputs.list"
    : > "${LIST}"

    # Build ordered list of this sample's interval GVCFs
    while read -r IVL; do
      if [ -z "${IVL}" ]; then
        continue
      fi

      F="${GVCF_DIR}/${SAMPLE}_${IVL}.g.vcf.gz"
      if [ -s "${F}" ]; then
        echo "${F}" >> "${LIST}"
      else
        echo "[WARN] Missing for ${SAMPLE}: ${F}" >> "logs/${SAMPLE}.gathervcfs.warn.log"
      fi
    done < "${INTERVALS_LIST}"

    OUT_GVCF="${OUT_DIR}/${SAMPLE}.g.vcf.gz"
    LOG="logs/${SAMPLE}.gathervcfs.log"

    gatk --java-options "-Xmx${JAVA_XMX}" GatherVcfs \
      -I "${LIST}" \
      -O "${OUT_GVCF}" \
      >> "${LOG}" 2>&1

    gatk IndexFeatureFile -I "${OUT_GVCF}" >> "${LOG}" 2>&1

    echo "[DONE] ${SAMPLE}" >> "${LOG}"
  ) &

  job_count=$((job_count + 1))
  if [ "${job_count}" -ge "${MAX_JOBS}" ]; then
    wait
    job_count=0
  fi
done

wait
echo "[DONE] All per-sample GVCFs gathered and indexed in: ${OUT_DIR}"
