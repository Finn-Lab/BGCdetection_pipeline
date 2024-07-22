#!/usr/bin/env python3

import gzip
import argparse
from Bio import SeqIO

def parse_gbk(file_handle):
    """Parse the GenBank file and yield (protein_id, sequence) tuples."""
    for record in SeqIO.parse(file_handle, "genbank"):
        for feature in record.features:
            if feature.type == "CDS" and "protein_id" in feature.qualifiers:
                protein_id = feature.qualifiers["protein_id"][0]
                if "translation" in feature.qualifiers:
                    sequence = feature.qualifiers["translation"][0].replace("*","")
                    yield protein_id, sequence

def read_gbk_file(input_file):
    """Read a GenBank file (can be gzipped) and return a generator of (protein_id, sequence) tuples."""
    if input_file.endswith('.gz'):
        with gzip.open(input_file, 'rt') as file_handle:
            for item in parse_gbk(file_handle):
                yield item
    else:
        with open(input_file, 'r') as file_handle:
            for item in parse_gbk(file_handle):
                yield item

def write_fasta(output_file, protein_sequences):
    """Write protein sequences to a gzipped FASTA file."""
    with gzip.open(output_file, 'wt') as file_handle:
        for protein_id, sequence in protein_sequences:
            file_handle.write(f">{protein_id}\n{sequence}\n")

def main():
    parser = argparse.ArgumentParser(description='Convert a GBK file to a FASTA file with protein sequences.')
    parser.add_argument('-i', '--input', required=True, help='Input GBK (or GBK.gz) file')
    parser.add_argument('-o', '--output', required=True, help='Output FASTA file')
    args = parser.parse_args()

    protein_sequences = read_gbk_file(args.input)
    write_fasta(args.output, protein_sequences)

if __name__ == "__main__":
    main()
