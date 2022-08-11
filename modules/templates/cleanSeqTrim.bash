#!/usr/bin/env bash

seqCleaner.pl \
  -seqFile masked.fa \
  -errorFile error.err \
  -trimDangling $params.trimDangling \
  -dangleMax $params.dangleMax \
  -outFile cleaned.fa 
