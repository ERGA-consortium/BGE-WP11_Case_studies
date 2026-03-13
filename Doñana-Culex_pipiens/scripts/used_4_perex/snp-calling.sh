#!/bin/bash

# Set strict mode
set -euo pipefail

#this script runs bcftools mpileup and call over all the bam files in a directory
# when they are divided by regions and then merge the vcf files

chromosome=${1} #1, 2 or 3
pop=${2}
samples=${3}
prefix=${4}
ref=${5}
thr=${6}

# Paths and variables
dir="/sietch_colab/scamison/talapas/SNPcalling"
reference="/sietch_colab/scamison/talapas/data/${ref}"
population_file="/sietch_colab/scamison/talapas/SNPcalling/${pop}"  # File with population information

# Chromosome BAM lists. list must contain the COMPLETE path to the bam files
list="${dir}/${samples}"

# Run bcftools mpileup and call
bcftools mpileup -Ou  --threads $thr -f $reference -q 20 -Q 15 -b $list -r "$chromosome" --annotate "FORMAT/AD,FORMAT/DP,INFO/AD" | \
bcftools call -m  --threads $thr -G $population_file -Ob --format-fields "GQ,GP" -o ${dir}/${prefix}_${chromosome}_pop.bcf


#bash snp-calling-poppy.sh 1 popperex.txt bams-perex.txt prefix ref.fasta 4