process GECCO_RUN {
    tag "$prefix"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gecco:0.9.8--pyhdfd78af_0':
        'biocontainers/gecco:0.9.8--pyhdfd78af_0' }"

    input:
    tuple val(prefix), path(input), path(hmm)
    path model_dir

    output:
    tuple val(prefix), path("*.clusters.gff.gz"), emit: gff_gz

    // Check if the output file exists in the publish directory
    // checkIf: !file("${System.getenv('PUBLISH_DIR_GECCO_RUN')}/${prefix}.clusters.gff.gz").exists()

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${prefix}"
    def custom_model = model_dir ? "--model ${model_dir}" : ""
    def custom_hmm = hmm ? "--hmm ${hmm}" : ""
    """
    trap 'find . -type f ! -name "${prefix}_gecco_*.gff.gz" ! -name ".*" -exec rm -rf {} +' EXIT

    gunzip -c ${input} > temp_file.gbk
    gecco \\
        run \\
        $args \\
        -j $task.cpus \\
        -o ./ \\
        -g temp_file.gbk \\
        $custom_model \\
        $custom_hmm \\
        || { echo "gecco error"; exit 1; }
    version=\$(echo \$(gecco --version | sed 's/^gecco //' ))
    touch ${prefix}.clusters.gff
    gecco convert clusters -i ./ --format gff
    gzip -c temp_file.clusters.gff > ${prefix}_gecco_\${version}.clusters.gff.gz
    """
}
