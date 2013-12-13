#!/bin/bash

## Set Path variables
AIP_HOME=/usr/local/projects/AIP
TAIR_DATA=DataProviders/TAIR
TAIR10_RELEASE=ftp.arabidopsis.org/Genes/TAIR10_genome_release

## Make custom TAIR10_genome release directory
mkdir -p ${AIP_HOME}/${TAIR_DATA}/custom_data/${TAIR10_RELEASE}/TAIR10_gff3

## Parse the functional description table and pick the appropriate columns
## to generate a 2-column tab delimited file (first column is equal to the
## ID features in the GFF3 files)
perl -lane '
    BEGIN { %data = (); }
    chomp;
    next unless /^AT/;
    @line = split /\t/;
    $val = ($line[2] eq "") ? $line[4] : $line[2];
    if($val =~ /;/) {
        @valp = split /;/, $val; $val = $valp[0];
    }
    $val = $line[3] if($val eq "");
    $val = "unknown protein" if($val =~ /^\D+ IN:/ or $val =~ /^CONTAINS /);
    ($locus, $isoform) = $line[0] =~ /^(\S+)\.(\d+)$/;
    if($isoform == 1) {
        $data{$locus} = $val;
        print join "\t", $locus, $val;
    }
    print join "\t", $line[0], $data{$locus};
    ' \
        ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_functional_descriptions \
        > ${AIP_HOME}/${TAIR_DATA}/custom_data/${TAIR10_RELEASE}/TAIR10_functional_descriptions.tsv

## Run the gff formatter script to fix the following issues:
## 1) Invent IDs for features that do not have an ID attribute
## 2) Make all the IDs unique, within the scope of the file
## 3) Add a note feature using the table created in the step above
## 4) Remove the "protein" feature (which is unwanted and now replaced in the SO by the term "polypeptide")
## 5) Verify feature types against the SO to resolve any unknown types (example: mRNA_TE_gene -> mRNA)
## Use code from the commit: https://github.com/tanghaibao/jcvi/commit/aaa6ab3
python -m jcvi.formats.gff format \
    --gff3 --unique --nostrict \
    --note=TAIR10_functional_descriptions.tsv \
    --remove_feat="protein" --verifySO="resolve" \
    ${AIP_HOME}/${TAIR_DATA}/${TAIR10_RELEASE}/TAIR10_gff3/TAIR10_GFF3_genes_transposons.gff \
    -o ${AIP_HOME}/${TAIR_DATA}/custom_data/${TAIR10_RELEASE}/TAIR10_gff3/TAIR10_GFF3_genes_transposons.gff \
    2> TAIR10_GFF3_genes_transposons.gff.format.log
