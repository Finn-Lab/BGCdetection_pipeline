#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Copyright 2024 EMBL - European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import gzip
from Bio import SeqIO
import tempfile
import os,sys,json,shutil,glob

def process_fasta_file(file_path):

    if file_path.endswith('.gz'):
        with gzip.open(file_path, 'rt') as handle:
            sequences = list(SeqIO.parse(handle, 'fasta'))
    else:
        with open(file_path, 'rt') as handle:
            sequences = list(SeqIO.parse(handle, 'fasta'))
    
    return sequences

def main(args=None):

    parser = argparse.ArgumentParser(description="build_gb. Tool to build genbank format files ")
    parser.add_argument(
        "-r",
        dest="a_res_dir",
        default=None,
        type=str,
        help="analysis result directory",
        metavar="PATH",
        required=True,
    )
    parser.add_argument(
        "-i",
        dest="a_inp",
        default=None,
        type=str,
        help="analysis input file",
        metavar="FILE",
        required=True,
    )
    parser.add_argument(
        "-o",
        dest="out_gbk",
        default=None,
        type=str,
        help="output genebank format file",
        metavar="FILE",
        required=True,
    )
    parser.add_argument(
        "-f",
        dest="out_faa",
        default=None,
        type=str,
        help="output genebank format file",
        metavar="FILE",
        required=True,
    )

    args = parser.parse_args(args)

    # os.makedirs(os.path.dirname(os.path.dirname(args.out_gbk)),exist_ok=True)

    ## Find files
 
    
    RESULTS_BASE_DIRS = ["/nfs/public/services/metagenomics/results","/nfs/production/rdf/metagenomics/results/"]
    # RESULTS_BASE_DIRS = ["/hps/nobackup/rdf/metagenomics/research-team/santiago/softw/BGCdetection_pipeline/test/files/"]
    # """ PROCESS WITHIN FILESYSTEM """
    for RESULTS_BASE_DIR in RESULTS_BASE_DIRS:
        flag = 0
        nuc_file = f"{RESULTS_BASE_DIR}/{args.a_res_dir}/{args.a_inp}.fasta.gz"
        if os.path.exists(nuc_file):
            flag+=1
        else:
            files = glob.glob(f"{RESULTS_BASE_DIR}/{args.a_res_dir}/{args.a_inp}*fasta.gz")
            if len(files)>0:
                nuc_file = files[0]
                if os.path.exists(nuc_file):
                    flag+=1
        aa_file = f"{RESULTS_BASE_DIR}/{args.a_res_dir}/{args.a_inp}_CDS.faa.gz"
        if os.path.exists(aa_file):
            flag+=1
        else:
            files = glob.glob(f"{RESULTS_BASE_DIR}/{args.a_res_dir}/{args.a_inp}*CDS*.faa.gz")
            if len(files)>0:
                aa_file = files[0]
                if os.path.exists(aa_file):
                    flag+=1    
        if flag:
            break

    if not flag:
        print(f"Error: couldn't find approapiate files", file=sys.stderr)
        sys.exit(1)
    fna = {rec.id:rec.seq for rec in process_fasta_file(nuc_file)} 
    faa = process_fasta_file(aa_file)

    feats = {}

    for ff in faa:
        spl = ff.description.split()
        try:
            s,e,st = int(spl[2])-1,int(spl[4]),int(spl[6])
        except:
            print(f'looks like {ff.id} doesnot have prodigal header structure. Ignoring')
            continue
        
        from Bio import SeqFeature
        start_pos = SeqFeature.ExactPosition(s)
        end_pos = SeqFeature.ExactPosition(e)

        from Bio.SeqFeature import FeatureLocation
        feature_location = FeatureLocation(start_pos,end_pos)

        feature_type = "CDS"

        from Bio.SeqFeature import SeqFeature
        qual = {}
        qual['translation'] = str(ff.seq).replace("*","")
        qual['protein_id'] = str(ff.id)
        feature = SeqFeature(feature_location,type=feature_type,qualifiers=qual)

        cont = "_".join(ff.id.split('_')[:-1])
        feats.setdefault(cont,[]).append(feature)

    recs = []
    for cont,v in feats.items():

        sequence = fna.get(cont)

        from Bio.SeqRecord import SeqRecord
        sequence_record = SeqRecord(sequence)    
        sequence_record.id = cont    
        sequence_record.name = cont    
        sequence_record.description = cont    
        sequence_record.annotations={"molecule_type": "DNA"}
        sequence_record.features = v
        recs.append(sequence_record)

    with open(args.out_gbk, 'w') as h:
        SeqIO.write(recs, h, 'genbank')
        
    shutil.copy2(aa_file, args.out_faa)

    print(f"Done!")

if __name__ == "__main__":
    main(sys.argv[1:])
