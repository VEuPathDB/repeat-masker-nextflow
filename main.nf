nextflow.enable.dsl=2

process repeatMasker {
    input:
    path 'subset.fa'

    output:
    path 'subset.fa.masked'        

    """
    RepeatMasker subset.fa 
    """
}

process cleanSequences {
    input:
    path 'masked.fa'

    output:
    path 'cleaned.fa'
    path 'error.err' 

    """
    seqCleaner.pl -seqFile masked.fa -errorFile error.err -trimDangling $params.trimDangling -dangleMax $params.dangleMax -outFile cleaned.fa
    """
}

workflow {
  masked = channel.fromPath(params.inputFilePath).splitFasta(by: params.fastaSubsetSize, file:true) | repeatMasker
  results = cleanSequences(masked)
  results[0] | collectFile(storeDir: params.outputDir, name: params.outputFileName)
  results[1] | collectFile(storeDir: params.outputDir)
}