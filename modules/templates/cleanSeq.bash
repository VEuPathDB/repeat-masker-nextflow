#!/usr/bin/env bash

set -euo pipefail

if [ "$trimDangling" = true ]; then

    seqCleaner.pl \
        -seqFile $maskedFasta \
        -errorFile error.err \
        -trimDangling $params.trimDangling \
        -dangleMax $params.dangleMax \
        -outFile cleaned.fa
   
else

    seqCleaner.pl \
        -seqFile $maskedFasta \
        -errorFile error.err \
        -dangleMax $params.dangleMax \
        -outFile cleaned.fa
    
fi
