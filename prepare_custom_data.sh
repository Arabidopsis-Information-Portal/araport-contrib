#!/bin/bash

## set path variables (source araport env)
source araport.env

mkdir -p $GO_ANNOT_CUSTOM

# extract all TAIR "locus" accessions from GFF3 which are not associated to feature type "gene"
# use these identifiers to look for matching lines in the GO annotation file and exclude all such lines
grep -P "locus:\d+" ${TAIR10_CUSTOM_GFF3}/TAIR10_GFF3_genes_transposons.gff | grep -vP "\tgene\t" \
    | perl -lane 'chomp; /(locus:\d+)/; print $1;' \
    | parallel -j16 grep -P "{}" ${GO_ANNOT}/gene_association.tair \
    | cut -f2 | sort -u | paste -d"|" -s - \
    | xargs -I{} grep -vP "{}" ${GO_ANNOT}/gene_association.tair \
    > ${GO_ANNOT_CUSTOM}/gene_association.tair
