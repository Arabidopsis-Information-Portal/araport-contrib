#!/bin/bash

## set Path variables (source araport env)
source araport.env

## make custom TAIR10_genome release directory
mkdir -p ${AIP_HOME}/${TAIR_DATA}/custom_data/${TAIR10_RELEASE}/TAIR10_gff3
cd ${AIP_HOME}/${TAIR_DATA}/custom_data/${TAIR10_RELEASE}/TAIR10_gff3

# prepare the necessary attribute data in tab-delimited files
grep '^AT' ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_functional_descriptions | cut -f1,3 | perl -lane 'BEGIN { %data = (); } chomp; @line = split /\t/; $line[0] =~ /(\S+)\.\d+/; $data{$1} = $line[-1]; print; END { for $locus(keys %data) { print join "\t", $locus, $data{$locus}; } }' | sort -k1,1 > Note.tsv
grep '^AT' ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_functional_descriptions | cut -f1,4 > Curator_summary.tsv
grep '^AT' ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_functional_descriptions | cut -f1,5 > Computational_description.tsv

grep -P "\tmRNA\t" ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_gff3/TAIR10_GFF3_genes_transposons.gff \
    | cut -f9 \
    | cut -f2,3 -d";" --output-delimiter="	" \
    | sed -r "s/Parent=|Name=//g" \
    | python -m jcvi.formats.base group --groupby=0 --nouniq - \
    | sort -k1,1 > gene_mRNA.map

cut -f1,2 ${AIP_HOME}/${TAIR_DATA}/Genes/gene_aliases_20130831.txt | python -m jcvi.formats.base group --groupby=0 --groupsep="," - | grep -P '^AT[A-z0-9]G' | sort -k1,1 | python -m jcvi.formats.base join --noheader gene_mRNA.map - | grep -vP "na" | cut -f1,2,4  | perl -lane 'BEGIN { %data = (); } chomp; @line = split /\t/; @mrna = split /,/, $line[1]; print join "\t", $line[0], $line[-1]; foreach $m(@mrna) { print join "\t", $m, $line[-1]; }' > Alias.tsv

python -m jcvi.formats.base reorder ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_TAIRAccessionID_AGI_mapping.txt 2,1 | grep -P '^AT[A-z0-9]G' | python -m jcvi.formats.base group --groupby=0 - --nouniq | sort -k1,1 | python -m jcvi.formats.base join --noheader gene_mRNA.map - | cut -f2,4 | python -m jcvi.formats.base flatten --sep="	" --zipflatten="," - | sed -e "s/,/\t/g" > Gene.tsv

# prepare the enriched GFF3 file with the required attributes
python -m jcvi.formats.gff format --gff3 --unique --nostrict --multiparents="merge" \
    --remove_feat="protein,chromosome" --verifySO="resolve" --add_dbxref="Gene.tsv" \
    --add_attribute="Alias.tsv,Note.tsv,Curator_summary.tsv,Computational_description.tsv" \
   ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_gff3/TAIR10_GFF3_genes_transposons.gff \
   2> format.gff.log | python -m jcvi.formats.gff sort --method="topo" stdin \
   -o TAIR10_GFF3_genes_transposons.gff
