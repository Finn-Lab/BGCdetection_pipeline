// # Copyright 2024 EMBL - European Bioinformatics Institute
// #
// # Licensed under the Apache License, Version 2.0 (the "License");
// # you may not use this file except in compliance with the License.
// # You may obtain a copy of the License at
// # http://www.apache.org/licenses/LICENSE-2.0
// #
// # Unless required by applicable law or agreed to in writing, software
// # distributed under the License is distributed on an "AS IS" BASIS,
// # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// # See the License for the specific language governing permissions and
// # limitations under the License.

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { BUILD_GBK                                  } from './modules/local/build_gbk'
include { ANTISMASH                                  } from './modules/local/antismash'
include { INTERPROSCAN                                } from './modules/local/interproscan'
include { SANNTIS                                    } from './modules/local/sanntis'

// include { DOWNLOAD_DATABASES                         } from './subworkflows/download_databases'
// /*
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//     IMPORT NF-CORE MODULES/SUBWORKFLOWS
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// */
include { GECCO_RUN                   } from './modules/nf-core/gecco/run/main'
/*

/////////////////////////////////////////////////////
/* --  Create channels for reference databases  -- */
/////////////////////////////////////////////////////
antismash_db = file(params.antismash_db, checkIfExists: true)
interproscan_db = file(params.interproscan_db, checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary

workflow  {
    // Capture the 'process' parameter from the command line
params.process = params.process ? params.process.split(',') : []

    // Check if the input file exists
    if (!file(params.input).exists()) {
        error "Input CSV file not found: ${params.input}"
    }

    // Reading the input samplesheet
    assemblies_dirs = Channel.fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> tuple(row.PREFIX, row.RESULT_DIRECTORY, row.INPUT_FILE_NAME) }

    // Define a helper function to check if a process should run
    def shouldRun = { processName -> params.process.size() == 0 || params.process.contains(processName) }

    // Conditional execution based on the 'process' parameter
    if (shouldRun('BUILD_GBK')) {
        BUILD_GBK(assemblies_dirs)
    }

    if (shouldRun('ANTISMASH')) {
        ANTISMASH(
            BUILD_GBK.out.gbk_gz,
            params.antismash_db
        )
    }

    if (shouldRun('INTERPROSCAN')) {
        INTERPROSCAN(
            BUILD_GBK.out.faa_gz,
            interproscan_db
        )
    }

    if (shouldRun('SANNTIS')) {
        SANNTIS(
            INTERPROSCAN.out.ips_tsv_gz,
            BUILD_GBK.out.gbk_gz
        )
    }

    if (shouldRun('GECCO_RUN')) {
        GECCO_RUN(
            BUILD_GBK.out.gbk_gz.map { prefix, gbk -> [prefix, gbk, []] }, []
        )
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/