/*
 * Make necesary GBK trandformation for dowstream analyses
*/
process EXTRACT_FAA_GZ{

    tag "${prefix}"
    input:
    tuple val(prefix), val(input_file)

    output:
    tuple val(prefix), file("${prefix}.faa.gz"), emit: faa_gz, optional: true

    // Check if the output file exists in the publish directory
    // checkIf: !file("${System.getenv('PUBLISH_DIR_BUILD_GBK')}/${prefix}.gbk.gz").exists()

    script:
    """
    python ${baseDir}/bin/extract_faa_gz.py \\
    -i ${input_file} -o ${prefix}.faa.gz \\
    """
}