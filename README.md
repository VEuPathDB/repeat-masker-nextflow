# repeat-masker-nextflow

Nextflow pipeline that masks repetitive and low-complexity DNA in genomic sequence using RepeatMasker, with automatic selection of the best-matching repeat library for the input organism.

## Overview

This pipeline runs [RepeatMasker](http://www.repeatmasker.org/) over an input genomic FASTA file to soft/hard-mask transposable elements and other repetitive sequence, as part of VEuPathDB's genome annotation workflows. Masking repetitive DNA upstream of gene prediction and other annotation steps prevents repeat sequence from being mis-annotated as coding or regulatory content.

Given a NCBI taxon ID, the pipeline queries the Dfam repeat family database (`famdb.py`) for the taxon's lineage, then uses NCBI E-utilities (`efetch`/`xtract`) to walk that lineage from most to least specific and select the closest ancestor taxon that has a named entry in Dfam (`findBestTaxonId`). This lets the pipeline mask genomes from species that aren't directly represented in Dfam by falling back to the best-matching taxonomic group. The input FASTA is split into subsets (sized as a fraction of the total sequence count) and RepeatMasker is run on each subset against the selected taxon's repeat library. Sequence deflines, which RepeatMasker can truncate or alter, are remapped before and restored after masking (`updateDefline.pl` / `restoreFastaDefline.pl`) so that output coordinates and IDs match the original input. RepeatMasker's `.out` report is converted to BED. The masked FASTA is then optionally cleaned to trim long dangling runs of masked (`N`) bases from sequence ends (`seqCleaner.pl`) before the final masked FASTA, error log, and indexed BED file are published.

## Requirements

- [Nextflow](https://www.nextflow.io/) (DSL2)
- Docker or Singularity, depending on the execution profile in the runtime configuration
- Network access to NCBI E-utilities from the execution environment (used to resolve taxon lineage)

## Usage

```
nextflow run VEuPathDB/repeat-masker-nextflow \
  -r main \
  -resume \
  --inputFilePath /path/to/genome.fasta \
  --taxonId 5833 \
  --subsetFractionDenominator 2 \
  --outputFileName masked.seq \
  --errorFileName masked.err \
  --outputDir /path/to/output \
  -C <config>
```

The pipeline has a single, unnamed entry point (no `-entry` flag is needed); it internally invokes the named `repeatMasker` sub-workflow defined in `modules/repeatMasker.nf`.

## Key parameters

| Parameter | Description |
| --- | --- |
| `inputFilePath` | Path to the input genomic FASTA file. Required. |
| `taxonId` | NCBI taxon ID for the source organism, used to select the closest matching Dfam repeat library. |
| `subsetFractionDenominator` | Divides the total input sequence count to determine how many sequences go into each parallel RepeatMasker subset job. Required. |
| `rmParams` | Additional command-line arguments passed directly to RepeatMasker (default `-xsmall`, which produces soft-masked lowercase output). |
| `trimDangling` | Whether to trim dangling runs of masked (`N`) bases from the ends of sequences after masking. |
| `dangleMax` | Maximum number of unmasked bases at a sequence end that will still be trimmed along with an adjacent run of 10+ masked bases when `trimDangling` is enabled. |
| `outputFileName` | Name of the published masked FASTA output and the base name of the indexed BED output. |
| `errorFileName` | Name of the published error/log file from the sequence-cleaning step. |
| `outputDir` | Directory the final outputs are published to (default `output` under the launch directory). |

Container images and process-level resources (executor, queue, memory) are supplied via the runtime configuration passed with `-C`, allowing the same pipeline definition to run under Docker, Singularity, or an LSF cluster profile (see `conf/docker.config`, `conf/singularity.config`, and `conf/lsf.config`). The pipeline's own image, built from the included `Dockerfile`, bundles RepeatMasker, RMBlast, and TRF.

## Output

For each run, the pipeline publishes to `outputDir`:

- `<outputFileName>` — the masked genomic FASTA (repetitive regions masked per `rmParams`, with original sequence IDs restored and optional dangling-mask trimming applied).
- `<errorFileName>` — a log of sequences excluded during cleaning (e.g. sequences too short after masking).
- `<outputFileName>.bed.gz` and `<outputFileName>.bed.gz.tbi` — a sorted, Tabix-indexed BED file of the RepeatMasker-called repeat regions.
