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

    // if (!file(params.input).exists()) {
    //     error "Input CSV file not found: ${params.input}"
    // }
    // Reading the input samplesheet
    assemblies_dirs = Channel.fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> tuple(row.prefix, row.result_directory, row.analysis_input_file) }

    BUILD_GBK( 
        assemblies_dirs 
        )

    ANTISMASH(
        BUILD_GBK.out.gbk,
        params.antismash_db
    )

    INTERPROSCAN(
        BUILD_GBK.out.faa,
        interproscan_db
        )

    SANNTIS(
        INTERPROSCAN.out.ips_tsv,
        BUILD_GBK.out.gbk 
        )

    GECCO_RUN(
        BUILD_GBK.out.gbk.map { prefix, gbk -> [prefix, gbk, []] }, []
    )

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

