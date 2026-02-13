#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process getLineage {
  container 'veupathdb/repeatmasker:1.4.0'
  input:
    val taxonId

  output:
    env lowestLineageId

  script:
    """
    famdb.py lineage -ad ${taxonId} > lineage.txt
    getLineage.pl --inputFile lineage.txt --outFile lowest_id.txt
    if [ ! -s "lowest_id.txt" ]; then
      export lowestLineageId=$taxonId
    else
      export lowestLineageId=\$(cat lowest_id.txt)
    fi
    """
}

process runEDirect {
  container 'veupathdb/edirect:1.0.0'
  input:
    val lowestLineageId

  output:
    path 'taxonIds.txt'

  script:
    """
    efetch -db taxonomy -id $lowestLineageId -format xml \
    | xtract -pattern Taxon -block LineageEx -sep "\n" -element TaxId > taxonIds.txt
    # Adds our input id to the file, as it is not
    echo "$lowestLineageId" >> taxonIds.txt
    """
}

process findBestTaxonId {
  container 'veupathdb/repeatmasker:1.4.0'
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
    if [ ! -f bestTaxon.txt ]; then
        echo "1" > bestTaxon.txt
    fi
    export bestTaxon=\$(cat bestTaxon.txt)
    """
}

process runRepeatMasker {
  container 'veupathdb/repeatmasker:1.4.0'
  input:
    path subsetFasta
    val bestTaxon

  output:
    path '*.masked', emit: mask
    path '*.bed', emit: bed

  script:
    log.info "The bestTaxonId chosen was ${bestTaxon}"
    template 'runRepeatMasker.bash'
}

process cleanSequences {
 container 'veupathdb/repeatmasker:1.4.0'
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
  container 'biocontainers/tabix:v1.9-11-deb_cv1'

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
    lowestTaxonId = getLineage(params.taxonId)							  
    taxonId = runEDirect(lowestTaxonId)
    bestTaxon = findBestTaxonId(taxonId)
    masked = runRepeatMasker(seqs, bestTaxon)

    index = indexResults(masked.bed, params.outputFileName+".bed")

    index.bed.collectFile(storeDir: params.outputDir)
    index.tbi.collectFile(storeDir: params.outputDir)

    results = cleanSequences(masked.mask, params.trimDangling)
    results.fasta | collectFile(storeDir: params.outputDir, name: params.outputFileName)
    results.error | collectFile(storeDir: params.outputDir, name: params.errorFileName)
}
