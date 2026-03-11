#!/bin/bash

# flagstat.sh
SAMPLE=$1
asm=$2

samtools flagstat bam/${SAMPLE}.bam > qc/${SAMPLE}.flagstat.txt
