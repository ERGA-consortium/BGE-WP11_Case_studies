#!/bin/bash

# split-interval.sh
SAMPLE=$1
asm=$2
  
gatk SplitIntervals \
  -R /media/labpc11c/DATA/neverMIND/draft_chrom/chrom.soft.fa \
  --scatter-count 20 \
  -O intervals/
  
  

