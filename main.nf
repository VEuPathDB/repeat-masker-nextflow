#!/usr/bin/env nextflow 

seq_qch = Channel.fromPath(params.inputFile).splitFasta( by:1, file:true  )

process repeatMasker {
    input:
    file 'subsetFile.fa' from seq_qch
    output:
    file 'outFile.seq' into output_qch
    file 'error.err' into error_qch    
    
    """
    perl $params.repeatMaskerPath --rmPath $params.rmPath --seqFile subsetFile.fsa --outFile outfile.seq --errorFile error.err --trimDangling $params.trimDangling --dangleMax $params.dangleMax --rmParamsFile $params.rmParamsFile
    """
}

results = output_qch.collectFile(name: 'outFile.seq')

errors = error_qch.collectFile(name: 'error.err')

process publishResults {
    input:
    file 'outFile.seq' from results
    
    """
    cat outFile.seq > $params.outputDir/results.txt
    """
}

process publishErrors {
    input:
    file 'error.err' from errors
    
    """
    cat error.err > $params.outputDir/error.err
    """
}  
