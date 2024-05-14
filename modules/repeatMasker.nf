#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process runRepeatMasker {
  input:
    path subsetFasta

  output:
    path '*.masked'         

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

workflow repeatMasker {
  take:
    inputFile

  main:
    seqs = Channel.fromPath( params.inputFilePath)
           .splitFasta( by:params.fastaSubsetSize, file:true  )
    masked = runRepeatMasker(seqs)
    results = cleanSequences(masked, params.trimDangling)
    results.fasta | collectFile(storeDir: params.outputDir, name: params.outputFileName)
    results.error | collectFile(storeDir: params.outputDir, name: params.errorFileName)
}