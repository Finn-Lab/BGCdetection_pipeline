/*
 * SMBGC Annotation using Neural Networks Trained on Interpro Signatures
*/
process SANNTIS {

    container 'quay.io/microbiome-informatics/sanntis:0.9.3.4'

    input:
    tuple val(prefix), path(ips_tsv_gz)
    tuple val(prefix), path(gbk_gz)

    output:
    tuple val(prefix), path("*_sanntis.gff.gz"), emit: gff_gz, optional: true
    
    // Check if the output file exists in the publish directory
    // checkIf: !file("${System.getenv('PUBLISH_DIR_SANNTIS')}/${prefix}_sanntis.gff.gz").exists()

    """
    trap 'find . -type f ! -name "${prefix}_sanntis.gff.gz" ! -name ".*" -exec rm -rf {} +' EXIT
    gunzip -c ${gbk_gz} > temp_file.gbk
    gunzip -c ${ips_tsv_gz} > temp_file.ips.tsv
    sanntis \\
    --ip-file temp_file.ips.tsv \\
    --outfile ${prefix}_sanntis.gff \\
    --cpu ${task.cpus} \\
    temp_file.gbk \\
    || { echo "sanntis error"; exit 1; }

    gzip -c ${prefix}_sanntis.gff > ${prefix}_sanntis.gff.gz
    """
}
