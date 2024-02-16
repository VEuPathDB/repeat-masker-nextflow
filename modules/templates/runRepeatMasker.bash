#!/usr/bin/env bash

set -euo pipefail
export LIBDIR=/opt/RepeatMasker/Libraries
RepeatMasker $params.rmParams $subsetFasta -dir .
expectedMaskedFile=${subsetFasta}.masked
if ! [-f \$expectedMaskedFile ]
then
  mv $subsetFasta expectedMaskedFile
fi
