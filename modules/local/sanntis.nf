/*
 * SMBGC Annotation using Neural Networks Trained on Interpro Signatures
*/
process SANNTIS {

    container 'quay.io/microbiome-informatics/sanntis:0.9.3.4'

    input:
    tuple val(prefix), path(ips_tsv)
    tuple val(prefix), path(gbk_file)
    output:
    tuple val(prefix), path("*_sanntis.gff.gz"), emit: gff_gz

    """
    sanntis \
    --ip-file ${ips_tsv} \
    --outfile ${prefix}_sanntis.gff \
    --cpu ${task.cpus} \
    ${gbk_file}

    gzip -c ${prefix}_sanntis.gff > ${prefix}_sanntis.gff.gz
    """
}
