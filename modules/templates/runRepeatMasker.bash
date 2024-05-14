#!/usr/bin/env bash
set -euo pipefail
RepeatMasker $params.rmParams $subsetFasta -dir .
expectedMaskedFile=${subsetFasta}.masked
if [ ! -f \$expectedMaskedFile ]; then
  mv $subsetFasta \$expectedMaskedFile
fi

