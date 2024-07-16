
process ANTISMASH {

    tag "${prefix}"

    container 'quay.io/microbiome-informatics/antismash:7.1.0.1_2'

    input:
    tuple val(prefix), path(gbk_gz)
    path(antismash_db)

    output:
    tuple val(prefix), path("${prefix}_antismash.gff.gz"), emit: gff, optional: true
    
    // Check if the output file exists in the publish directory
    // checkIf: !file("${System.getenv('PUBLISH_DIR_ANTISMASH')}/${prefix}_antismash.gff.gz").exists()
    
    script:
    """
    trap 'find . -type f ! -name "${prefix}_antismash.gff.gz" ! -name ".*" -exec rm -rf {} +' EXIT


    antismash \\
    -t bacteria \\
    -c ${task.cpus} \\
    --databases ${antismash_db} \\
    --output-basename ${prefix} \\
    --genefinding-tool none \\
    --output-dir ${prefix}_results \\
    ${gbk_gz} || { echo "antismash error"; exit 1; }


    # To build the GFF3 file the scripts needs the regions.js file to be converted to json
    # In order to do that this process uses nodejs (using a patched version of the antismash container)

    echo ";var fs = require('fs'); fs.writeFileSync('./regions.json', JSON.stringify(recordData));" >> ${prefix}_results/regions.js

    node ${prefix}_results/regions.js

    antismash_to_gff.py \\
        -r regions.json -a \$(echo \$(antismash --version | sed 's/^antiSMASH //' )) \\
        -o ${prefix}_antismash.gff
        
    gzip -c ${prefix}_antismash.gff > ${prefix}_antismash.gff.gz
    """
}
