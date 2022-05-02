#!/usr/bin/env nextflow 

seq_qch = Channel.fromPath(params.inputFilePath).splitFasta( by:1, file:true  )

process repeatMasker {
    container = 'dfam/tetools'

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
    output:
    file 'cleaned.fa' into cleaned_qch
    file 'error.err' into error_qch 
    """
    perl $params.seqCleanerPath -seqFile $params.inputFilePath --errorFile error.err --trimDangling $params.trimDangling --dangleMax $params.dangleMax --outFile cleaned.fa
    """
}

results = cleaned_qch.collectFile(name: 'cleaned.fa')

errors = error_qch.collectFile(name: 'error.err')

process publishResults {
    input:
    file 'cleaned.fa' from results    
    """
    cat cleaned.fa > $params.outputDir/output.fa
    """
}

process publishErrors {
    input:
    file 'error.err' from errors
    
    """
    cat error.err > $params.outputDir/error.err
    """
}
