/*
 * Make necesary GBK trandformation for dowstream analyses
*/
process BUILD_GBK{

    tag "${prefix}"
    input:
    tuple val(prefix), val(result_directory), val(input_file)
    output:
    tuple val(prefix), file("${prefix}.gbk"), emit: gbk
    tuple val(prefix), file("${prefix}.gbk.gz"), emit: gbk_gz
    tuple val(prefix), file("${prefix}.faa"), emit: faa
    script:
    """
    python ${baseDir}/bin/build_gbk.py -r ${result_directory} -i ${input_file} -o ${prefix}.gbk -f ${prefix}.faa.gz
    gunzip -c ${prefix}.faa.gz > ${prefix}.faa
    gzip -c ${prefix}.gbk > ${prefix}.gbk.gz
    """
}