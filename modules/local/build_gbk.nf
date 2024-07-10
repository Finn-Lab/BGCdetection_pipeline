/*
 * Make necesary GBK trandformation for dowstream analyses
*/
process BUILD_GBK{

    tag "${prefix}"
    input:
    tuple val(prefix), val(result_directory), val(input_file)
    output:
    tuple val(prefix), file("${prefix}.gbk"), emit: gbk, optional: true
    tuple val(prefix), file("${prefix}.gbk.gz"), emit: gbk_gz, optional: true
    tuple val(prefix), file("${prefix}.faa"), emit: faa, optional: true
    tuple val(prefix), file("${prefix}.no_files.txt"), emit: err_file, optional: true
    script:
    """
    python ${baseDir}/bin/build_gbk.py -r ${result_directory} -i ${input_file} -o ${prefix}.gbk -f ${prefix}.faa.gz || { echo "File not found"; exit 1; }
    if [[ ! -f ${prefix}.gbk ]]; then
        touch ${prefix}.no_files.txt
        exit 1
    fi
    gunzip -c ${prefix}.faa.gz > ${prefix}.faa
    gzip -c ${prefix}.gbk > ${prefix}.gbk.gz
    """
}