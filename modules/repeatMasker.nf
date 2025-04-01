#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process runEDirect {
  container = 'veupathdb/edirect:1.0.0'
  input:
    val taxonId

  output:
    path 'taxonIds.txt'

  script:
    """
    efetch -db taxonomy -id $taxonId -format xml \
    | xtract -pattern Taxon -block LineageEx -sep "\n" -element TaxId > taxonIds.txt
    echo "$taxonId" >> taxonIds.txt
    """
}

process findBestTaxonId {
  container = 'veupathdb/repeatmasker:1.0.0'
  input:
    path taxonIds

  output:
    env bestTaxon

  script:
    """
    tac $taxonIds > flipped.txt
    cat flipped.txt | while read line; do
      famdb.py names "\$line" >> temp.txt
      if grep -q "Exact Matches" temp.txt; then
        echo "\$line" > bestTaxon.txt
      	break
      fi
    done
    export bestTaxon=\$(cat bestTaxon.txt)
    """
}

process runRepeatMasker {
  container = 'veupathdb/repeatmasker:1.0.0'
  input:
    path subsetFasta
    val bestTaxon

  output:
    path '*.masked', emit: mask
    path '*.bed', emit: bed

  script:
    template 'runRepeatMasker.bash'
}

process cleanSequences {
 container = 'veupathdb/repeatmasker:1.0.0'
  input:
    path maskedFasta
    val trimDangling

  output:
    path 'cleaned.fa', emit: fasta 
    path 'error.err', emit: error

  script:
    template 'cleanSeq.bash'
}

process indexResults {
  container = 'biocontainers/tabix:v1.9-11-deb_cv1'

  input:
    path bed
    val outputFileName

  output:
    path '*.bed.gz', emit: bed
    path '*.tbi', emit: tbi

  script:
  """
  sort -k1,1 -k2,2n $bed > ${outputFileName}
  bgzip ${outputFileName}
  tabix -p bed ${outputFileName}.gz
  """
}

workflow repeatMasker {
  take:
    inputFile

  main:
    seqs = Channel.fromPath(params.inputFilePath).flatMap { fraction = it.countFasta() / params.subsetFractionDenominator
                                                            it.splitFasta(by: fraction.toInteger(), file: true);
							  }

    taxonId = runEDirect(params.taxonId)
    bestTaxon = findBestTaxonId(taxonId)
    masked = runRepeatMasker(seqs, bestTaxon)

    index = indexResults(masked.bed, params.outputFileName+".bed")

    index.bed.collectFile(storeDir: params.outputDir)
    index.tbi.collectFile(storeDir: params.outputDir)

    results = cleanSequences(masked.mask, params.trimDangling)
    results.fasta | collectFile(storeDir: params.outputDir, name: params.outputFileName)
    results.error | collectFile(storeDir: params.outputDir, name: params.errorFileName)
}
