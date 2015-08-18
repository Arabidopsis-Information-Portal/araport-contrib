#!/bin/bash

## set up the environment
## and import the data configuration file
source araport.env $*
source data.cfg

## make custom TAIR10_genome release directory
mkdir -p ${TAIR10_CUSTOM_GFF3} && cd ${TAIR10_CUSTOM_GFF3}

# prepare locus_type tsv file
grep -P '^AT[A-z0-9]G' ${FUNC_DESC} | cut -f1,2 | sort -k1,1 \
    | perl -lane 'BEGIN { %d = (); } chomp; @l = split /\t/; $l[0] =~ /(\S+)\.(\d+)/; $d{$1} = $l[1] if(not defined $d{$1} and $l[1] ne ""); END { for $locus(keys %d) { print join "\t", $locus, $d{$locus}; } }' \
    | sort -k1,1 > Locus_type.tsv

# prepare note, curator_summary and computational_description tsv files
declare -A descrs=( ["3"]="Note" ["4"]="Curator_summary" ["5"]="Computational_description" )
for col in "${!descrs[@]}"; do

    grep -P '^AT[A-z0-9]G' ${FUNC_DESC} | cut -f1,$col | sort -k1,1 \
        | perl -lane 'BEGIN { %d = (); } chomp; @l = split /\t/; $l[0] =~ /(\S+)\.(\d+)/; $d{$1} = $l[1] if(not defined $d{$1} and $l[1] ne ""); print; END { for $locus(keys %d) { print join "\t", $locus, $d{$locus}; } }' \
        | sort -k1,1 > ${descrs["$col"]}.tsv
done

awk '{ if($2 == "") print $0"unknown protein"; else print $0 }' Note.tsv > temp.tsv
mv temp.tsv Note.tsv

declare -A confs=( ["3"]="conf_rating" ["4"]="conf_class" )
for col in "${!confs[@]}"; do
    sed -e "s/ | /\t/g" ${CONF_RANKING} \
        | grep '^AT' | cut -f1,$col > ${confs["$col"]}.tsv
done

grep -P "RNA\t|transcript\t" ${SOURCE_GFF} \
    | cut -f9 | cut -f2,3 -d";" --output-delimiter="	" \
    | sed -r "s/Parent=|Name=//g" \
    | python -m jcvi.formats.base group --groupby=0 --nouniq - \
    | sort -k1,1 > gene_transcript.map

cut -f1,2 ${LOCUS_PRIMARY_SYM} \
    | grep -P '^AT[A-z0-9]G' | sort -k1,1 \
    | python -m jcvi.formats.base join --noheader gene_transcript.map - \
    | grep -vP "\tna$" | cut -f1,2,4 \
    | perl -lane 'chomp; @l = split /\t/; print join "\t", $l[0], $l[2]; foreach $m(split /,/, $l[1]) { print join "\t", $m, $l[2]; }' \
    > Symbol.tsv

cut -f1,3 ${LOCUS_PRIMARY_SYM} \
    | grep -P '^AT[A-z0-9]G' | sort -k1,1 \
    | python -m jcvi.formats.base join --noheader gene_transcript.map - \
    | grep -vP "\tna$" | cut -f1,2,4 \
    | perl -lane 'chomp; @l = split /\t/; print join "\t", $l[0], $l[2]; foreach $m(split /,/, $l[1]) { print join "\t", $m, $l[2]; }' \
    > Full_name.tsv

perl -lane 'chomp; @l = split /\t/; if(scalar @l == 2) { print; } else { $desc = $l[2]; $desc =~ s/,/%2C/gs; $desc =~ s/\"//gs; print join "\t", $l[0], "$l[1]~~~$desc"; }' ${GENE_ALIASES} \
    | cut -f1,2 \
    | python -m jcvi.formats.base group --groupby=0 --groupsep="," --nouniq - \
    | grep -P '^AT[A-z0-9]G' | sort -k1,1 \
    | python -m jcvi.formats.base join --noheader gene_transcript.map ${LOCUS_PRIMARY_SYM} - \
    | grep -vP "\tna$" | cut -f1,2,4,7 \
    | perl -lane 'chomp; @l = split /\t/; %aliases = map { $_ => 1 } (split /,/, $l[-1]); $l[2] = undef if($l[2] eq "na"); foreach $k(keys %aliases) { delete $aliases{$k} if($k =~ /^\b$l[2]\b/); } $alias = join ",", sort keys %aliases; print join "\t", $l[0], $alias if($alias ne ""); foreach $m(split /,/, $l[1]) { print join "\t", $m, $alias if($alias ne ""); }' \
    | sed -e "s/~~~/,/g" \
    > Alias.tsv

python -m jcvi.formats.base reorder ${NCBI_AGI_MAPPING} 2,1 \
    | grep -P '^AT[A-z0-9]G' | sort -k1,1 -k2,2n | python -m jcvi.formats.base group --groupby=0 --nouniq - \
    | sort -k1,1 | python -m jcvi.formats.base join --noheader gene_transcript.map - \
    | cut -f2,4 | python -m jcvi.formats.base flatten --sep="	" --zipflatten="," - \
    | sed -e "s/,/\t/g" \
    > gene.tsv

python -m jcvi.formats.base reorder ${TAIR_AGI_MAPPING} 2,1 \
    | grep -P '^AT[A-z0-9]G' | python -m jcvi.formats.base group --groupby=0 --nouniq - \
    | sort -k1,1 > locus.tsv

cut -f1,3 ${LOCUS_PUBLISHED} \
    | grep -P '^AT[A-z0-9]G' | python -m jcvi.formats.base group --groupby=0 --nouniq - \
    | sort -k1,1 > PMID.tsv

# prepare the enriched GFF3 file with the required attributes
python -m jcvi.formats.gff format --nostrict --invent_name_attr --multiparents="merge" \
    --remove_feats="protein,chromosome" --remove_attr="Derives_from" \
    --add_dbxref="locus.tsv,gene.tsv,PMID.tsv" --note="Note.tsv" \
    --add_attribute="Locus_type.tsv,Alias.tsv,conf_class.tsv,conf_rating.tsv,Full_name.tsv,Curator_summary.tsv,Computational_description.tsv,Symbol.tsv" \
   ${SOURCE_GFF} 2> format.gff.log \
   | gt gff3 -sort -tidy -retainids -addids no - \
   > TAIR10_GFF3_genes_transposons.AIP.gff

cd -
