# BGC Detection Pipeline

This repository contains a Nextflow pipeline for detecting Biosynthetic Gene Clusters (BGCs) in metagenomic assemblies using the tools antiSMASH, GECCO, and SanntiS. This pipeline is designed to be run on EBI_SLURM.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Input Files](#input-files)
- [Output Files](#output-files)
- [Output Directory Structure](#output-directory-structure)
- [Pipeline Structure](#pipeline-structure)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Installation

### Clone the Repository

```bash
git clone https://github.com/Finn-Lab/BGCdetection_pipeline.git
cd BGCdetection_pipeline
python -m pip install -e .
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
- `--process`: To run specific processes. Provide processes names separated by comma, e.g. `BUILD_GBK,ANTISMASH`. If the argument is not provided, all processes will be run.

## Configuration

The pipeline uses various configuration files to customize execution for different environments:

- `conf/base.config`: Base configuration for most high-performance compute environments.
- `conf/ebi_codon.config`: Specific configurations for the EBI Codon cluster.
- `conf/modules.config`: Configuration for individual modules.
- `conf/test.config`: Configuration for running minimal tests.


## Input Files

The input CSV file should contain the following columns:

- `PREFIX`: Prefix for the output files, typically formatted as `"{ASSEMBLY_FILE_NAME}_{md5sum(RESULT_DIRECTORY)}"`.
- `GBK_GZ`: Input file for the analysis (Absolute path). Genebank file with protein and nucleotide sequneces. Best if output of [assembly_extraction_pipeline](https://github.com/Finn-Lab/BGCdetection_pipeline.git).

Example:

```csv
PREFIX,GBK_GZ
ERZ6863740_FASTA_5d9374cdf7a9f3b3ee89d860a60abe88,/home/User/ERZ6863740_FASTA/ERZ6863740_FASTA.gbk.gz
ERZ9863740_FASTA_9d9374cdf7a9f3b3ee89d860a60abe88,/home/UserERZ6863740_FASTA/ERZ9863740_FASTA.gbk.gz
```

## Output Files

The pipeline generates various output files in the specified output directory:

- GFF files with BGC annotations from antiSMASH, GECCO, and SanntiS.
- TSV files with InterProScan results.

## Output Directory Structure

The output directory structure is defined using Nextflow's `publishDir` directive. The output GenBank files will be organized in subdirectories based on the prefix:

```
<outdir>/
  ├── <last_two_characters_of_prefix>/
  │   └── <full_prefix>/
  │       └── <analysis>/
  │           └── *.gff.gz|*.IPS.tsv.gz
```

## Pipeline Structure

The pipeline is composed of several Nextflow processes and modules:

- **EXTRACT_FAA_GZ**: Generates protein FASTA file to be used in interproscan.
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



