# BGC Detection Pipeline

This repository contains a Nextflow pipeline for detecting Biosynthetic Gene Clusters (BGCs) in metagenomic assemblies using the tools antiSMASH, GECCO, and SanntiS. This pipeline is designed to be run on EBI_SLURM.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Input Files](#input-files)
- [Output Files](#output-files)
- [Pipeline Structure](#pipeline-structure)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Installation

### Prerequisites

- Nextflow: [Installation instructions](https://www.nextflow.io/docs/latest/getstarted.html)
- Docker or Singularity (recommended for managing dependencies)

### Clone the Repository

```bash
git clone https://github.com/Finn-Lab/BGCdetection_pipeline.git
cd BGCdetection_pipeline
```

## Usage

### Test

```bash
nextflow run main.nf -profile debug --input test/files/dummy_input.csv --outdir TEST_OUTPUT
```

### Full Run

To run the pipeline on a larger dataset, provide an appropriate configuration and input file:

```bash
nextflow run main.nf -profile ebi --input <path_to_input_csv> --outdir <output_directory>
```

### Parameters

- `--input`: Path to the CSV file containing input information.
- `--outdir`: Directory where the output files will be stored.
#### Options
- `--min_lenght_contig`: Defines the minimum length of contig to process. Increasing this value can speed up processing by excluding shorter contigs. Default = 3000.

## Configuration

The pipeline uses various configuration files to customize execution for different environments:

- `conf/base.config`: Base configuration for most high-performance compute environments.
- `conf/ebi_codon.config`: Specific configurations for the EBI Codon cluster.
- `conf/modules.config`: Configuration for individual modules.
- `conf/test.config`: Configuration for running minimal tests.


## Input Files

The input CSV file should contain the following columns:

- `prefix`: Prefix for the output files, typically formatted as `"{INPUT_FILE_NAME}_{md5(RESULT_DIRECTORY)}"`.
- `result_directory`: Directory containing the result files from MGnify pipeline. RESULT_DIRECTORY column of emg.ANALYSIS_JOB table. The workflow will look for these in the "/nfs/public/services/metagenomics/results" or "/nfs/production/rdf/metagenomics/results/" base directories in the LTS filesystem.
- `analysis_input_file`: Input file for the analysis. INPUT_FILE_NAME column of emg.ANALYSIS_JOB table.

This format is typically extracted from the EMG database, table `ANALYSIS_JOB`.

Example:

```csv
prefix,result_directory,analysis_input_file
ERZ6863740_FASTA_5d9374cdf7a9f3b3ee89d860a60abe88,2024/03/ERP135446/version_5.0/ERZ686/000/ERZ6863740_FASTA,ERZ6863740_FASTA
ERZ6864647_FASTA_65b16210f3b5b37490e5bd28c43d78f7,2024/03/ERP135446/version_5.0/ERZ686/007/ERZ6864647_FASTA,ERZ6864647_FASTA
```

## Output Files

The pipeline generates various output files in the specified output directory:

- GFF files with BGC annotations from antiSMASH, GECCO, and SanntiS.
- GenBank format files for further analysis.
- TSV files with InterProScan results.

## Pipeline Structure

The pipeline is composed of several Nextflow processes and modules:

- **BUILD_GBK**: Generates GenBank files from input FASTA files.
- **ANTISMASH**: Runs antiSMASH for BGC detection.
- **INTERPROSCAN**: Runs InterProScan for protein domain prediction.
- **SANNTIS**: Annotates BGCs using neural networks trained on InterPro signatures.
- **GECCO_RUN**: Runs GECCO for BGC prediction.

## Contributing

We welcome contributions to improve this pipeline. Please fork the repository and submit a pull request.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This pipeline is a modification of [mettannotator](https://github.com/EBI-Metagenomics/mettannotator.git). Special thanks to the MGnify team for their work on the original pipeline.
