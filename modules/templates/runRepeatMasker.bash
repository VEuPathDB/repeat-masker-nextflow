#!/usr/bin/env bash

set -euo pipefail
export LIBDIR=$params.libraryPath
RepeatMasker $params.rmParams $subsetFasta -dir .
if ! [-f "subset.fa.masked"]
then
  mv $subsetFasta subset.fa.masked
fi
