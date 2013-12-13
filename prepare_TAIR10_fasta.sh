#!/bin/bash

## Set Path variables
AIP_HOME=/usr/local/projects/AIP
TAIR_DATA=DataProviders/TAIR
CHRS_FASTA=ftp.arabidopsis.org/Sequences/whole_chromosomes

## Prepare custom data directory using the same folder structure as TAIR ftp
mkdir -p ${AIP_HOME}/${TAIR_DATA}/custom_data/${CHRS_FASTA}

## Concatenate all chromosome and organelle FASTA into one file
## Fix fasta headers to match the reference sequence identifiers in the GFF3 file
cat ${AIP_HOME}/${TAIR_DATA}/${CHRS_FASTA}/TAIR10_chr?.fas \
    | sed -e "s/chloroplast/ChrC/g" -e "s/mitochondria/ChrM/g" \
    > ${AIP_HOME}/${TAIR_DATA}/custom_data/${CHRS_FASTA}/TAIR10_genome.fas
