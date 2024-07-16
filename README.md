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

### Clone the Repository

```bash
git clone https://github.com/Finn-Lab/BGCdetection_pipeline.git
cd BGCdetection_pipeline
```

### Prerequisites

- Docker or Singularity, Nextflow, and Biopython, which can be installed the provided `environment.yml` file for setting up a conda environment. Follow these steps to create and activate the environment:

  1. **Install Conda**: If you do not have conda installed, download and install it from [Conda's official site](https://docs.conda.io/projects/conda/en/latest/user-guide/install/).

  2. **Create the Environment**:
    ```bash
    conda env create -f environment.yml
    ```

  3. **Activate the Environment**:
    ```bash
    conda activate BGCdetection_pipeline
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
- `--process`: To run specific processes. Provide processes names separated by comma, e.g. `BUILD_GBK,ANTISMASH`. If the argument is not provided, all processes will be run.

## Configuration

The pipeline uses various configuration files to customize execution for different environments:

- `conf/base.config`: Base configuration for most high-performance compute environments.
- `conf/ebi_codon.config`: Specific configurations for the EBI Codon cluster.
- `conf/modules.config`: Configuration for individual modules.
- `conf/test.config`: Configuration for running minimal tests.


## Input Files

The input CSV file should contain the following columns:

- `PREFIX`: Prefix for the output files, typically formatted as `"{INPUT_FILE_NAME}_{md5sum(RESULT_DIRECTORY)}"`.
- `RESULT_DIRECTORY`: Directory containing the result files from MGnify pipeline. RESULT_DIRECTORY column of emg.ANALYSIS_JOB table. The workflow will look for these in the "/nfs/public/services/metagenomics/results" or "/nfs/production/rdf/metagenomics/results/" base directories in the LTS filesystem.
- `INPUT_FILE_NAME`: Input file for the analysis. INPUT_FILE_NAME column of emg.ANALYSIS_JOB table.

The file can be created as follows:

``` bash
QUERY="SELECT RESULT_DIRECTORY,INPUT_FILE_NAME FROM ANALYSIS_JOB WHERE EXPERIMENT_TYPE_ID=4"

# Output CSV file
OUTPUT_CSV="pipeline_input.csv"

# Temporary files
TMP_CSV="tmp_output.csv"

# Execute MySQL query and save output to a temporary CSV file
mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME -e "$QUERY" --batch| awk 'BEGIN {FS="\t"; OFS=","} {print $1, $2}' > $TMP_CSV

# Add PREFIX column with MD5 sum of RESULT_DIRECTORY
awk 'BEGIN {FS=OFS=","} 
NR==1 {print $0} 
NR>1 { 
  cmd="echo -n "$1" | md5sum | awk \x27{print $1}\x27"; 
  cmd | getline md5; 
  close(cmd); 
  prefix=$2 "_" md5; 
  print prefix, $0 
}' $TMP_CSV > $OUTPUT_CSV

sed -i '1s/RESULT_DIRECTORY,INPUT_FILE_NAME/PREFIX,RESULT_DIRECTORY,INPUT_FILE_NAME/' $OUTPUT_CSV
# Clean up temporary files
rm -f $TMP_CSV
```


This format is typically extracted from the EMG database, table `ANALYSIS_JOB`.

Example:

```csv
PREFIX,RESULT_DIRECTORY,INPUT_FILE_NAMEPREFIX
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



