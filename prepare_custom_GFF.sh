#!/bin/bash

## Set Path variables
AIP_HOME=/usr/local/projects/AIP
TAIR_DATA=DataProviders/TAIR
TAIR9_RELEASE=ftp.arabidopsis.org/Genes/TAIR9_genome_release

## Prepare data directories
mkdir -p ${AIP_HOME}/${TAIR_DATA}/custom_data/${TAIR9_RELEASE}/TAIR9_gff3/Expression_GFF
mkdir -p ${AIP_HOME}/${TAIR_DATA}/custom_data/${TAIR9_RELEASE}/TAIR9_gff3/Community_annotation_GFF

python -m jcvi.formats.gff format --gff --unique ${AIP_HOME}/${TAIR_DATA}/${TAIR9_RELEASE}/TAIR9_gff3/Expression_GFF/tair9_smallRNA_17_summary.gff > ${AIP_HOME}/${TAIR_DATA}/custom_data/${TAIR9_RELEASE}/TAIR9_gff3/Expression_GFF/tair9_smallRNA_17_summary.gff

sed -e "s/quesneville_//g" ${AIP_HOME}/${TAIR_DATA}/${TAIR9_RELEASE}/TAIR9_gff3/Community_annotation_GFF/tair9_Quesneville_Transposons_20090429.gff > ${AIP_HOME}/${TAIR_DATA}/custom_data/${TAIR9_RELEASE}/TAIR9_gff3/Community_annotation_GFF/tair9_Quesneville_Transposons_20090429.gff

python -m jcvi.formats.gff chain ${AIP_HOME}/${TAIR_DATA}/${TAIR9_RELEASE}/TAIR9_gff3/Expression_GFF/tair9_atproteometair7.gff > ${AIP_HOME}/${TAIR_DATA}/custom_data/${TAIR9_RELEASE}/TAIR9_gff3/Expression_GFF/tair9_atproteometair7.gff

sed -e "s/_match2/_match/g" ${AIP_HOME}/${TAIR_DATA}/${TAIR9_RELEASE}/TAIR9_gff3/Expression_GFF/tair9_Briggs_atproteome7_20090401.gff > tmp$$.gff3 \
    && python -m jcvi.formats.gff chain tmp$$.gff3 > ${AIP_HOME}/${TAIR_DATA}/custom_data/${TAIR9_RELEASE}/TAIR9_gff3/Expression_GFF/tair9_Briggs_atproteome7_20090401.gff \
    && rm tmp$$.gff3
