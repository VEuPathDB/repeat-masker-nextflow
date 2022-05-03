nextflow.enable.dsl=1
seq_qch = Channel.fromPath(params.inputFilePath).splitFasta( by:1, file:true  )

process repeatMasker {
    container = 'dfam/tetools:latest'

    input:
    file 'subsetFile.fa' from seq_qch
    output:
    file 'masked.fa' into masked_qch
        
    """
    RepeatMasker subsetFile.fa
    cat subsetFile.fa.masked > masked.fa 
    """
}

process cleanSequences {
    input:
    file 'masked.fa' from masked_qch
    output:
    file 'cleaned.fa' into cleaned_qch
    file 'error.err' into error_qch 
    """
    perl $params.seqCleanerPath -seqFile masked.fa -errorFile errorFile.err -trimDangling $params.trimDangling -dangleMax $params.dangleMax -outFile cleanedFile.fa
    cat errorFile.err > error.err
    cat cleanedFile.fa > cleaned.fa
    """
}

results = cleaned_qch.collectFile(storeDir: params.outputDir)
errors = error_qch.collectFile(storeDir: params.outputDir)


