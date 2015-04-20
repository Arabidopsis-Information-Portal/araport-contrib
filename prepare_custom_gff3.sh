#!/bin/bash

## set up the environment
## and import the data configuration file
source araport.env $*
source data.cfg

mkdir -p $TAIR9_CUSTOM_GFF3/Expression_GFF
mkdir -p $TAIR9_CUSTOM_GFF3/Community_annotation_GFF

## TMP filename
TMP=tmp$$

python -m jcvi.formats.gff format --gff --nostrict --unique ${SRNA_GFF} \
    > $TAIR9_CUSTOM_GFF3/Expression_GFF/tair9_smallRNA_17_summary.gff

sed -e "s/quesneville_//g" ${TRANSP_GFF} \
    > $TAIR9_CUSTOM_GFF3/Community_annotation_GFF/tair9_Quesneville_Transposons_20090429.gff

python -m jcvi.formats.gff chain --transfer_attrib="minscore,maxscore,Dbxref,Note,Alias" \
    --transfer_score="mean" ${ATPROT_GFF} \
    > $TAIR9_CUSTOM_GFF3/Expression_GFF/tair9_atproteometair7.gff

sed -e "s/_match2/_match/g" ${BRIGGS_ATPROT_GFF} > $TMP.gff3 \
    && python -m jcvi.formats.gff chain \
    --transfer_attrib="Name,FullPeptide,Translation" \
    --transfer_score="mean" $TMP.gff3 -o \
    $TAIR9_CUSTOM_GFF3/Expression_GFF/tair9_Briggs_atproteome7_20090401.gff \
    && rm $TMP.gff3

mkdir -p $TAIR10_CUSTOM_GFF3

sed -e "s/exon/match/g" ${SPL_JUNCS_GFF} > $TMP.gff3 \
    && python -m jcvi.formats.gff chain --transfer_attrib="Name,Note,Overlap" \
    $TMP.gff3 -o $TAIR10_CUSTOM_GFF3/Spliced_Junctions_clustered.gff \
    && rm $TMP.gff3
