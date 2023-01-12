#!/usr/bin/env bash

set -euo pipefail
seqCleaner.pl \
  -seqFile $maskedFasta \
  -errorFile error.err \
  -dangleMax $params.dangleMax \
  -outFile cleaned.fa 
