#!/usr/bin/env nextflow 

seq_qch = Channel.fromPath(inputFile).splitFasta( by:1, file:true  )

process splitFastaIntoFiles {
    input:
    file 'seq.fa' from seq_qch
    output:
    file 'subsetFile.fa' into subsetFile_qch
    shell:
    """
    cat seq.fa > subsetFile.fa
    """
}

process repeatMasker {
    input:
    file 'subsetFile.fa' from subsetFile_qch
    output:
    file 'outFile.seq' into output_qch
    file 'error.err' into error_qch    
    
    """
    perl $params.rmPath --seqFile subsetFile.fsa --outFile outfile.seq --errorFile error.err --trimDangling $params.trimDangling --dangleMax $params.dangleMax --rmParamsFile $params.rmParamsFile
    """
}

results = output_qch.collectFile(name: 'outFile.seq')

errors = error_qch.collectFile(name: 'error.err')

process publishResults {
    input:
    file 'outFile.seq' from results
    
    """
    cat outFile.seq > $params.outFile
    """
}

process publishErrors {
    input:
    file 'error.err' from errors
    
    """
    cat error.err > $params.errorFile
    """
}  
