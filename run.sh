#!/bin/bash

## run script to prepare TAIR genome fasta file
./prepare_TAIR10_fasta.sh $*

## run script to prepare enriched TAIR annotation GFF file
./prepare_TAIR10_gff3.sh $*

## run script to prepare other custom GFF files
./prepare_custom_gff3.sh $*

## run script to prepare other custom datasets (GO annotation, etc.)
./prepare_custom_data.sh $*
