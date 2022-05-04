nextflow.enable.dsl=1
seq_qch = Channel.fromPath(params.inputFilePath).splitFasta( by:1, file:true  )

process repeatMasker {
    
    input:
    file 'subset.fa' from seq_qch
    output:
    file 'subset.fa.masked' into masked_qch
        
    """
    RepeatMasker subset.fa 
    """
}

process cleanSequences {
    input:
    file 'masked.fa' from masked_qch
    output:
    file 'cleaned.fa' into cleaned_qch
    file 'error.err' into error_qch 
    """
    seqCleaner.pl -seqFile masked.fa -errorFile error.err -trimDangling $params.trimDangling -dangleMax $params.dangleMax -outFile cleaned.fa
    """
}

results = cleaned_qch.collectFile(storeDir: params.outputDir, name: params.outputFileName)
errors = error_qch.collectFile(storeDir: params.outputDir)


