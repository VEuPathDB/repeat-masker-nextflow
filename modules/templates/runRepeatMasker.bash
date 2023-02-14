#!/usr/bin/env bash

set -euo pipefail
export LIBDIR=/opt/RepeatMasker/Libraries
RepeatMasker $params.rmParams $subsetFasta -dir .
if ! [-f "subset.fa.masked"]
then
  mv $subsetFasta subset.fa.masked
fi
