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
    path 'cleaned.fa' 
    path 'error.err' 

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
    results[0] | collectFile(storeDir: params.outputDir, name: params.outputFileName)
    results[1] | collectFile(storeDir: params.outputDir, name: params.errorFileName)
}