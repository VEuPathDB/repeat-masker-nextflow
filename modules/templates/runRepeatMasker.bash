#!/usr/bin/env bash
set -euo pipefail
echo "Startup"
CURRENT_DIR=\$(pwd)
cd /opt/RepeatMasker/ && perl ./configure \
  -hmmer_dir=/opt/hmmer/bin \
  -rmblast_dir=/opt/rmblast/bin \
  -libdir=/opt/RepeatMasker/Libraries/ \
  -trf_prgm=/opt/trf \
  -default_search_engine=rmblast
echo "Done Config"
cd \$CURRENT_DIR
RepeatMasker $params.rmParams $subsetFasta -dir .
expectedMaskedFile=${subsetFasta}.masked
if [ ! -f \$expectedMaskedFile ]; then
  mv $subsetFasta \$expectedMaskedFile
fi

