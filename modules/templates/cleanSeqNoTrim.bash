#!/usr/bin/env bash

seqCleaner.pl \
  -seqFile masked.fa \
  -errorFile error.err \
  -dangleMax $params.dangleMax \
  -outFile cleaned.fa 
