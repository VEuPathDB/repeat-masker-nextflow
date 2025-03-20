#!/usr/bin/env bash
set -euo pipefail

updateDefline.pl \
        --inFasta $subsetFasta \
        --mappingFile mapping.tsv \
        --newFasta updatedFasta.fa \

RepeatMasker $params.rmParams -species $bestTaxon updatedFasta.fa -dir . -gff

if [ ! -f updatedFasta.fa.masked ]; then
    mv $subsetFasta ${subsetFasta}.masked
    touch ${subsetFasta}.out.gff
else
    restoreFastaDefline.pl \
	--inFasta updatedFasta.fa \
	--mappingFile mapping.tsv \
	--restoredFasta ${subsetFasta}.masked
    updateGff.pl \
	 --inGff updatedFasta.fa.out.gff \
	 --mappingFile mapping.tsv \
	 --newGff ${subsetFasta}.out.gff
fi
sed -i 1,2d ${subsetFasta}.out.gff
cut -f 1,4,5 ${subsetFasta}.out.gff > rows
awk '\$2--{print}' rows > ${subsetFasta}.bed
sed -i 's/\s/\t/g' ${subsetFasta}.bed


