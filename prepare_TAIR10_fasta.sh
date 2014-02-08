#!/bin/bash

## set path variables (source araport env)
source araport.env

## Prepare custom Chromosome FASTA data directory using the same folder structure as TAIR ftp
mkdir -p ${AIP_HOME}/${TAIR_DATA}/custom_data/${CHRS_FASTA}
cd ${AIP_HOME}/${TAIR_DATA}/custom_data/${CHRS_FASTA}

## Concatenate all chromosome and organelle FASTA into one file
## Fix fasta headers to match the reference sequence identifiers in the GFF3 file
sed -e "s/^>chloroplast/>ChrC/g" -e "s/^>mitochondria/>ChrM/g" \
    ${AIP_HOME}/${TAIR_DATA}/${CHRS_FASTA}/TAIR10_chr?.fas \
    > TAIR10_Chrs.fas

## save md5sum to a txt file to track in github (since file is too large to version control)
md5sum $PWD/TAIR10_Chrs.fas > TAIR10_Chrs.fas.md5sum

## Prepare custom CDS FASTA data directory using the same folder structure as TAIR ftp
mkdir -p ${AIP_HOME}/${TAIR_DATA}/custom_data/${CDS_FASTA}
cd ${AIP_HOME}/${TAIR_DATA}/custom_data/${CDS_FASTA}

## Prepare the TAIR10 CDS fasta file (fix the chromosome location identifiers)
sed -e "s/chr\([0-9A-Z]\):/Chr\1:/g" -e "s/\*/-/g" ${AIP_HOME}/${TAIR_DATA}/${CDS_FASTA}/TAIR10_cds_20101214_updated \
    > TAIR10_cds_20101214_updated

## save md5sum to a txt file to track in github (since file is too large to version control)
md5sum $PWD/TAIR10_cds_20101214_updated > TAIR10_cds_20101214_updated.md5sum
