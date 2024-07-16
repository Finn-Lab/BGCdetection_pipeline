/*
 * Make necesary GBK trandformation for dowstream analyses
*/
process BUILD_GBK{

    tag "${prefix}"
    input:
    tuple val(prefix), val(result_directory), val(input_file)

    output:
    tuple val(prefix), file("${prefix}.gbk.gz"), emit: gbk_gz, optional: true
    tuple val(prefix), file("${prefix}.faa.gz"), emit: faa_gz, optional: true

    // Check if the output file exists in the publish directory
    // checkIf: !file("${System.getenv('PUBLISH_DIR_BUILD_GBK')}/${prefix}.gbk.gz").exists()

    script:
    """
    python ${baseDir}/bin/build_gbk.py \\
    -r ${result_directory} \\
    -i ${input_file} -o ${prefix}.gbk \\
    -f ${prefix}.faa.gz \\
    -b ${params.basedir_filesystem} \\
    -m ${params.min_lenght_contig} \\
    || { echo "File not found"; exit 1; }
    trap 'rm -f ${prefix}.gbk' EXIT
    gzip -c ${prefix}.gbk > ${prefix}.gbk.gz
    """
}