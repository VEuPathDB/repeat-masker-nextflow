#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process runRepeatMasker {
  input:
    path subsetFasta

  output:
    path '*.masked', emit: mask
    path '*.bed', emit: bed

  script:
    template 'runRepeatMasker.bash'
}

process cleanSequences {
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

  publishDir params.outputDir, mode: 'copy'

  input:
    path bed
    val outputFileName

  output:
    path '*.bed.gz'
    path '*.tbi'

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
    seqs = Channel.fromPath( params.inputFilePath)
           .splitFasta( by:params.fastaSubsetSize, file:true  )
    masked = runRepeatMasker(seqs)
    indexed = indexResults(masked.bed.collectFile(), params.outputFileName+".bed")
    results = cleanSequences(masked.mask, params.trimDangling)
    results.fasta | collectFile(storeDir: params.outputDir, name: params.outputFileName)
    results.error | collectFile(storeDir: params.outputDir, name: params.errorFileName)
}