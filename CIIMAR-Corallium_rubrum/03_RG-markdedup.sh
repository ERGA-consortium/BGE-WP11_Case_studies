#!/bin/bash

# RG_markdedup.sh
SAMPLE=$1
asm=$2

#ReadGroup
gatk AddOrReplaceReadGroups \
  -I bam/${SAMPLE}.bam \
  -O bam/dedup/${SAMPLE}.withRG.bam \
  -RGID 1 -RGLB lib1 -RGPL illumina -RGPU unit1 -RGSM sample_name
  

# Mark Duplicates
gatk MarkDuplicates \
  -I bam/dedup/${SAMPLE}.withRG.bam \
  -O bam/dedup/${SAMPLE}.withRG.dedup.bam \
  -M qc/${SAMPLE}.withRG.dup.txt

#index
samtools index bam/dedup/${SAMPLE}.withRG.dedup.bam

