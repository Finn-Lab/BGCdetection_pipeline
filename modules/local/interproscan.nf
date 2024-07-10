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
    tuple val(prefix), path(faa_fasta)
    path(interproscan_db)

    output:
    tuple val(prefix), path('*.IPS.tsv'), emit: ips_tsv
    tuple val(prefix), path('*.IPS.tsv.gz'), emit: ips_tsv_gz

    script:
    """
    interproscan.sh \
    -cpu ${task.cpus} \
    -appl Pfam,NCBIfam,Gene3D,PRINTS,ProSitePatterns \
    -dp \
    --goterms \
    -f TSV \
    --input ${faa_fasta} \
    -o ${prefix}.IPS.tsv
    gzip -c ${prefix}.IPS.tsv > ${prefix}.IPS.tsv.gz
    """
}
