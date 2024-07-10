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

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${prefix}"
    def custom_model = model_dir ? "--model ${model_dir}" : ""
    def custom_hmm = hmm ? "--hmm ${hmm}" : ""
    """
    gecco \\
        run \\
        $args \\
        -j $task.cpus \\
        -o ./ \\
        -g ${input} \\
        $custom_model \\
        $custom_hmm

    touch ${prefix}.clusters.gff
    touch ${prefix}.clusters.testt
    gecco convert clusters -i ./ --format gff
    gzip -c ${prefix}.clusters.gff > ${prefix}.clusters.gff.gz
    """
}
