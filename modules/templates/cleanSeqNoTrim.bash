#!/usr/bin/env bash

set -euo pipefail
seqCleaner.pl \
  -seqFile masked.fa \
  -errorFile error.err \
  -dangleMax $params.dangleMax \
  -outFile cleaned.fa 
