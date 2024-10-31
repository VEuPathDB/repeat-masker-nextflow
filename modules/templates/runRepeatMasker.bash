#!/usr/bin/env bash
set -euo pipefail
RepeatMasker $params.rmParams $subsetFasta -dir . -gff
expectedMaskedFile=${subsetFasta}.masked
if [ ! -f \$expectedMaskedFile ]; then
    mv $subsetFasta \$expectedMaskedFile
    touch ${subsetFasta}.out.gff
fi
sed -i 1,2d ${subsetFasta}.out.gff
cut -f 1,4,5 ${subsetFasta}.out.gff > rows
awk '\$2--{print}' rows > ${subsetFasta}.bed
sed -i 's/\s/\t/g' ${subsetFasta}.bed


