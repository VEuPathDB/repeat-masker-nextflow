#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//--------------------------------------------------------------------------
// Param Checking
//--------------------------------------------------------------------------

if(!params.fastaSubsetSize) {
  throw new Exception("Missing params.fastaSubsetSize")
}

if(!params.inputFilePath) {
  throw new Exception("Missing params.seqFile")  
}

//--------------------------------------------------------------------------
// Includes
//--------------------------------------------------------------------------

include { repeatMasker } from './modules/repeatMasker.nf'

//--------------------------------------------------------------------------
// Main Workflow
//--------------------------------------------------------------------------

workflow {
  repeatMasker(params.inputFilePath)
}