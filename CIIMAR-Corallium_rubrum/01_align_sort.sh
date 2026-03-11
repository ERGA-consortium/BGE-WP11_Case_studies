#!/bin/bash

# align_and_sort.sh
SAMPLE=$1
ASM=$2

bwa mem -M -t 16 /media/labpc11c/DATA/neverMIND/draft_chrom/${ASM}.soft.fa ${SAMPLE}_1.trim.fq.gz ${SAMPLE}_2.trim.fq.gz | \
  samtools sort -@8 -o bam/${SAMPLE}.bam


#TODONEXT samtools flagstat bam/${SAMPLE}.${asm}.bam > qc/${SAMPLE}.${asm}.flagstat.txt

