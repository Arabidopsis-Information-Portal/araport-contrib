#!/bin/bash

## Set Path variables
AIP_HOME=/usr/local/projects/AIP
TAIR_DATA=DataProviders/TAIR
TAIR10_RELEASE=ftp.arabidopsis.org/Genes/TAIR10_genome_release

## Make custom TAIR10_genome release directory
mkdir -p ${AIP_HOME}/${TAIR_DATA}/custom_data/${TAIR10_RELEASE}/TAIR10_gff3

# prepare the necessary attribute data in tab-delimited files
grep 'AT' ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_NCBI_mapping_files/TAIR10_NCBI_REFSEQ_mapping_RNA | cut -f2,3 | python -m jcvi.formats.base reorder - 2,1 > GB.tsv
grep '^AT' ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_genome_release/TAIR10_functional_descriptions | cut -f1,3 | perl -lane 'BEGIN { %data = (); } chomp; @line = split /\t/; $line[0] =~ /(\S+)\.\d+/; $data{$1} = $line[-1]; print; END { for $locus(keys %data) { print join "\t", $locus, $data{$locus}; } }' | sort -k1,1 > Note.tsv
grep '^AT' ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_genome_release/TAIR10_functional_descriptions | cut -f1,4 > Curator_summary.tsv
grep '^AT' ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_genome_release/TAIR10_functional_descriptions | cut -f1,5 > Computational_description.tsv

sed -e "s/ | /\t/g" ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_genome_release/TAIR10_gene_confidence_ranking/confidenceranking_gene | grep '^AT' | cut -f1,4 > conf_class.tsv
sed -e "s/ | /\t/g" ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_genome_release/TAIR10_gene_confidence_ranking/confidenceranking_gene | grep '^AT' | cut -f1,3 > conf_rating.tsv

# prepare the enriched GFF3 file with the required attributes
python -m jcvi.formats.gff format --gff3 --unique --nostrict \
    --remove_feat="protein" --verifySO="resolve" --dbxref="GB.tsv" \
    --add_attribute="Note.tsv,Curator_summary.tsv,Computational_description.tsv,conf_class.tsv,conf_rating.tsv" \
   ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_gff3/TAIR10_GFF3_genes_transposons.gff \
   -o TAIR10_GFF3_genes_transposons.gff3 2> format.gff.log
