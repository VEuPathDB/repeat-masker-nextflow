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
    publishDir params.outputDir, mode: 'copy', saveAs: {filename -> filename.endsWith(".fa") ? params.outputFileName : filename }

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
  channel.fromPath(params.inputFilePath).splitFasta(by: params.fastaSubsetSize, file:true) | repeatMasker | cleanSequences
}