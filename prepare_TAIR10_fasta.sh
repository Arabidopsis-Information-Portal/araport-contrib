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
    > TAIR10_Chr.all.fasta

## save md5sum to a txt file to track in github (since file is too large to version control)
md5sum $PWD/TAIR10_Chr.all.fasta > TAIR10_Chr.all.fasta.md5sum

## Prepare custom CDS FASTA data directory using the same folder structure as TAIR ftp
mkdir -p ${AIP_HOME}/${TAIR_DATA}/custom_data/${ANNOT_FASTA}
cd ${AIP_HOME}/${TAIR_DATA}/custom_data/${ANNOT_FASTA}

## Prepare all TAIR10 fasta file(s)
## Fix the chromosome location identifiers in the header to make sure they match with the chromosome FASTA headers
for file in ${AIP_HOME}/${TAIR_DATA}/${ANNOT_FASTA}/TAIR10*; do
    fname=`basename ${file}`
    sed -e "s/chr\([0-9A-Z]\):/Chr\1:/g" -e "s/\*/-/g" ${file} > ${fname}.fasta
done
md5sum TAIR10*.fasta > TAIR10_blastsets.md5sum

## modify header of all the upstream and downstream FASTA sequences
for seqtype in upstream_sequences downstream_sequences; do
    mkdir -p $seqtype
    for file in ${AIP_HOME}/${TAIR_DATA}/${ANNOT_FASTA}/${seqtype}/*; do
        fname=`basename ${file}`
        sed -e "s/chr\([0-9A-Z]\):/Chr\1:/g" -e "s/\*/-/g" ${file} > ${seqtype}/${fname}.fasta
    done
done
