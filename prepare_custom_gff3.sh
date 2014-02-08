#!/bin/bash

## set path variables (source araport env)
source araport.env

mkdir -p $TAIR9_CUSTOM_GFF3/Expression_GFF
mkdir -p $TAIR9_CUSTOM_GFF3/Community_annotation_GFF

## TMP filename
TMP=tmp$$

python -m jcvi.formats.gff format --gff --unique $TAIR9_gff3/Expression_GFF/tair9_smallRNA_17_summary.gff > $TAIR9_CUSTOM_GFF3/Expression_GFF/tair9_smallRNA_17_summary.gff

sed -e "s/quesneville_//g" $TAIR9_gff3/Community_annotation_GFF/tair9_Quesneville_Transposons_20090429.gff > $TAIR9_CUSTOM_GFF3/Community_annotation_GFF/tair9_Quesneville_Transposons_20090429.gff

python -m jcvi.formats.gff chain --transfer_attrib="minscore,maxscore,Dbxref,Note,Alias" --transfer_score="mean" $TAIR9_gff3/Expression_GFF/tair9_atproteometair7.gff > $TAIR9_CUSTOM_GFF3/Expression_GFF/tair9_atproteometair7.gff

sed -e "s/_match2/_match/g" $TAIR9_gff3/Expression_GFF/tair9_Briggs_atproteome7_20090401.gff > $TMP.gff3 \
    && python -m jcvi.formats.gff chain --transfer_attrib="Name,FullPeptide,Translation" --transfer_score="mean" $TMP.gff3 -o $TAIR9_CUSTOM_GFF3/Expression_GFF/tair9_Briggs_atproteome7_20090401.gff \
    && rm $TMP.gff3

mkdir -p $TAIR10_CUSTOM_GFF3

sed -e "s/exon/match/g" $TAIR10_GFF3/Spliced_Junctions_clustered.gff > $TMP.gff3 \
    && python -m jcvi.formats.gff chain --transfer_attrib="Name,Note,Overlap" $TMP.gff3 -o $TAIR10_CUSTOM_GFF3/Spliced_Junctions_clustered.gff \
    && rm $TMP.gff3
