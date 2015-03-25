#!/bin/bash

## set up the environment
## and import the data configuration file
source araport.env $*
source data.cfg

## Prepare custom Chromosome FASTA data directory using the same folder structure as TAIR ftp
mkdir -p ${CUSTOM_CHRS_FASTA}
cd ${CUSTOM_CHRS_FASTA}

## Concatenate all chromosome and organelle FASTA into one file
## Fix fasta headers to match the reference sequence identifiers in the GFF3 file
sed -e "s/^>chloroplast/>ChrC/g" -e "s/^>mitochondria/>ChrM/g" ${GENOME_FASTA} \
    > TAIR10_Chr.all.fasta

## save md5sum to a txt file to track in github (since file is too large to version control)
md5sum TAIR10_Chr.all.fasta > TAIR10_Chr.all.fasta.md5sum

## Prepare custom CDS FASTA data directory using the same folder structure as TAIR ftp
cd -
mkdir -p ${CUSTOM_ANNOT_FASTA}
cd ${CUSTOM_ANNOT_FASTA}

## Prepare all TAIR10 fasta file(s)
## Fix the chromosome location identifiers in the header to make sure they match with the chromosome FASTA headers
for file in ${BLASTSETS_FASTA}; do
    fname=`basename ${file}`
    sed -e "s/chr\([0-9A-Z]\):/Chr\1:/g" -e "s/\*/-/g" ${file} > ${fname}.fasta
done
md5sum TAIR10*.fasta > TAIR10_blastsets.md5sum

## modify header of all the upstream and downstream FASTA sequences
for seqtype in ${SEQTYPES}; do
    mkdir -p $seqtype
    for file in ${ANNOT_FASTA}/${seqtype}/*; do
        fname=`basename ${file}`
        sed -e "s/chr\([0-9A-Z]\):/Chr\1:/g" -e "s/\*/-/g" ${file} > ${seqtype}/${fname}.fasta
    done
done

cd -
