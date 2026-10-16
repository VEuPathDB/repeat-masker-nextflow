#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//--------------------------------------------------------------------------
// Param Checking
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Includes
//--------------------------------------------------------------------------

include { repeatMasker } from './modules/repeatMasker.nf'

//--------------------------------------------------------------------------
// Main Workflow
//--------------------------------------------------------------------------

workflow {
  if(!params.subsetFractionDenominator) {
    error "Missing params.subsetFractionDenominator"
  }

  if(!params.inputFilePath) {
    error "Missing params.seqFile"
  }

  repeatMasker(params.inputFilePath)
}