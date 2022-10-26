#!/usr/bin/env nextflow
nextflow.enable.dsl=2


process runRepeatMasker {
  input:
    path 'subset.fa'

  output:
    path 'subset.fa.masked'         

  script:
    template 'runRepeatMasker.bash'
}


process cleanSequences {
  input:
    path 'masked.fa'

  output:
    path 'cleaned.fa', emit: fasta 
    path 'error.err', emit: error

  script:
    if (params.trimDangling)
      template 'cleanSeqTrim.bash'
    else
      template 'cleanSeqNoTrim.bash'
}


workflow repeatMasker {
  take:
    seqs

  main:

    masked = runRepeatMasker(seqs)
    results = cleanSequences(masked)
    results.fasta | collectFile(storeDir: params.outputDir, name: params.outputFileName)
    results.error | collectFile(storeDir: params.outputDir, name: params.errorFileName)
    
}