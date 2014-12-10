#!/bin/bash

## set Path variables (source araport env)
source araport.env

## make custom TAIR10_genome release directory
mkdir -p ${AIP_HOME}/${TAIR_DATA}/custom_data/${TAIR10_RELEASE}/TAIR10_gff3
cd ${AIP_HOME}/${TAIR_DATA}/custom_data/${TAIR10_RELEASE}/TAIR10_gff3

# prepare the necessary attribute data in tab-delimited files
export TAIR10_func_desc=${AIP_HOME}/${TAIR_DATA}/Jan2014_updates/gene_description_20140101.txt

# prepare the Note.tsv file
#["3"]="Note"
#grep -P '^AT[A-z0-9]G' ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/$TAIR10_func_desc | cut -f1,3 \
    #| awk '{ if($2 == "") print $0"unknown protein"; else print $0 }' | sort -k1,1 > Note.tsv

# prepare locus_type tsv file
grep -P '^AT[A-z0-9]G' ${TAIR10_func_desc} | cut -f1,2 | sort -k1,1 \
    | perl -lane 'BEGIN { %data = (); } chomp; @line = split /\t/; $line[0] =~ /(\S+)\.(\d+)/; $data{$1} = $line[1] if(not defined $data{$1} and $line[1] ne ""); END { for $locus(keys %data) { print join "\t", $locus, $data{$locus}; } }' \
    | sort -k1,1 > Locus_type.tsv

# prepare note, curator_summary and computational_description tsv files
declare -A descrs=( ["3"]="Note" ["4"]="Curator_summary" ["5"]="Computational_description" )
for col in "${!descrs[@]}"; do

    grep -P '^AT[A-z0-9]G' ${TAIR10_func_desc} | cut -f1,$col | sort -k1,1 \
        | perl -lane 'BEGIN { %data = (); } chomp; @line = split /\t/; $line[0] =~ /(\S+)\.(\d+)/; $data{$1} = $line[1] if(not defined $data{$1} and $line[1] ne ""); print; END { for $locus(keys %data) { print join "\t", $locus, $data{$locus}; } }' \
        | sort -k1,1 > ${descrs["$col"]}.tsv
done

awk '{ if($2 == "") print $0"unknown protein"; else print $0 }' Note.tsv > temp.tsv
mv temp.tsv Note.tsv

declare -A confs=( ["3"]="conf_rating" ["4"]="conf_class" )
for col in "${!confs[@]}"; do
    sed -e "s/ | /\t/g" ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_gene_confidence_ranking/confidenceranking_gene \
        | grep '^AT' | cut -f1,$col > ${confs["$col"]}.tsv
done

grep -P "\tmRNA\t" ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_gff3/TAIR10_GFF3_genes_transposons.gff \
    | cut -f9 \
    | cut -f2,3 -d";" --output-delimiter="	" \
    | sed -r "s/Parent=|Name=//g" \
    | python -m jcvi.formats.base group --groupby=0 --nouniq - \
    | sort -k1,1 > gene_mRNA.map

cut -f1,2 ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/../Locus_Primary_Gene_Symbol_20130117.txt \
    | grep -P '^AT[A-z0-9]G' | sort -k1,1 \
    | python -m jcvi.formats.base join --noheader gene_mRNA.map - \
    | grep -vP "\tna$" | cut -f1,2,4 \
    | perl -lane 'chomp; @line = split /\t/; print join "\t", $line[0], $line[2]; foreach $m(split /,/, $line[1]) { print join "\t", $m, $line[2]; }' \
    > Symbol.tsv

cut -f1,3 ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/../Locus_Primary_Gene_Symbol_20130117.txt \
    | grep -P '^AT[A-z0-9]G' | sort -k1,1 \
    | python -m jcvi.formats.base join --noheader gene_mRNA.map - \
    | grep -vP "\tna$" | cut -f1,2,4 \
    | perl -lane 'chomp; @line = split /\t/; print join "\t", $line[0], $line[2]; foreach $m(split /,/, $line[1]) { print join "\t", $m, $line[2]; }' \
    > Name.tsv

export GENE_ALIASES=${AIP_HOME}/${TAIR_DATA}/Jan2014_updates/gene_aliases_20140101
cut -f1,2 ${GENE_ALIASES} \
    | python -m jcvi.formats.base group --groupby=0 --groupsep="," --nouniq - \
    | grep -P '^AT[A-z0-9]G' | sort -k1,1 \
    | python -m jcvi.formats.base join --noheader gene_mRNA.map ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/../Locus_Primary_Gene_Symbol_20130117.txt - \
    | grep -vP "\tna" | cut -f1,2,4,7 \
    | perl -lane 'chomp; @line = split /\t/; %aliases = map { $_ => 1 } (split /,/, $line[-1]); $line[2] = undef if($line[2] eq "na"); delete $aliases{$line[2]}; $alias = join ",", sort keys %aliases; print join "\t", $line[0], $alias if($alias ne ""); foreach $m(split /,/, $line[1]) { print join "\t", $m, $alias if($alias ne ""); }' \
    > Alias.tsv

python -m jcvi.formats.base reorder ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_TAIRAccessionID_AGI_mapping.txt 2,1 \
    | grep -P '^AT[A-z0-9]G' | sort -k1,1 -k2,2n | python -m jcvi.formats.base group --groupby=0 --nouniq - \
    | sort -k1,1 | python -m jcvi.formats.base join --noheader gene_mRNA.map - \
    | cut -f2,4 | python -m jcvi.formats.base flatten --sep="	" --zipflatten="," - \
    | sed -e "s/,/\t/g" \
    > gene.tsv

python -m jcvi.formats.base reorder ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_TAIRlocusaccessionID_AGI_mapping.txt 2,1 \
    | grep -P '^AT[A-z0-9]G' | python -m jcvi.formats.base group --groupby=0 --nouniq - \
    | sort -k1,1 > locus.tsv

# prepare the enriched GFF3 file with the required attributes
python -m jcvi.formats.gff format --nostrict --invent_name_attr --multiparents="merge" \
    --remove_feat="protein,chromosome" --verifySO="resolve:prefix" --remove_attr="Derives_from" \
    --add_dbxref="locus.tsv,gene.tsv" --note="Note.tsv" \
    --add_attribute="Locus_type.tsv,Alias.tsv,conf_class.tsv,conf_rating.tsv,Full_name.tsv,Curator_summary.tsv,Computational_description.tsv,Symbol.tsv" \
   ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_gff3/TAIR10_GFF3_genes_transposons.gff \
   2> format.gff.log | python -m jcvi.formats.gff sort --method="topo" stdin \
   -o TAIR10_GFF3_genes_transposons.AIP.gff
