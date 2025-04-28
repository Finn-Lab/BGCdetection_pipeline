/*
 * Interproscan
*/

process INTERPROSCAN {

    tag "${prefix}"

    container 'quay.io/microbiome-informatics/genomes-pipeline.ips:5.62-94.0'
    containerOptions {
        if (workflow.containerEngine == 'singularity') {
            return "--bind ${interproscan_db}/data:/opt/interproscan-5.62-94.0/data"
        } else {
            return "-v ${interproscan_db}/data:/opt/interproscan-5.62-94.0/data"
        }
    }

    input:
    tuple val(prefix), path(faa_gz)
    path(interproscan_db)

    output:
    tuple val(prefix), path('*.IPS.tsv.gz'), emit: ips_tsv_gz, optional: true

    // Check if the output file exists in the publish directory
    // checkIf: !file("${System.getenv('PUBLISH_DIR_INTERPROSCAN')}/${prefix}.IPS.tsv.gz").exists()

    script:
    """
    trap 'find . -type f ! -name "${prefix}_interproscan_*IPS.tsv.gz" ! -name ".*" -exec rm -rf {} +' EXIT
    gunzip -c ${faa_gz} |sed 's/*//' > temp.fasta

    interproscan.sh \\
    -cpu ${task.cpus} \\
    -appl Pfam,NCBIfam,Gene3D,PRINTS,ProSitePatterns \\
    -dp \\
    --goterms \\
    -f TSV \\
    --input temp.fasta \\
    -o ${prefix}.IPS.tsv \\
    || { echo "IPS error"; exit 1; }

    version=\$(interproscan.sh --version | grep -o "InterProScan version [0-9.-]*" | sed "s/InterProScan version //")
    gzip -c ${prefix}.IPS.tsv > ${prefix}_interproscan_\${version}.IPS.tsv.gz
    """
}
