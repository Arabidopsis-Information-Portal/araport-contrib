#!/bin/bash
## download_tair_data.sh :: vkrishna :: 10/22/2013
## Download all relevant datasets from TAIR ftp

user="anonymous"
passwd="vkrishna@jcvi.org"
wgetcmd="wget --ftp-user=\"$user\" --ftp-password=\"$passwd\" -r -nv"
ftproot="ftp://ftp.arabidopsis.org"

# Gene related files (GFF3, Blastsets)
for dir in TAIR10 TAIR9 TAIR8; do
    $wgetcmd $ftproot/Genes/$dir\_genome_release
    $wgetcmd $ftproot/Sequences/blast_datasets/$dir\_blastsets
done
$wgetcmd $ftproot/Maps/gbrowse_data

## Sequence files
for dir in whole_chromosomes markers chloroplast mitochondrial; do
    $wgetcmd --level=1 $ftproot/Sequences/$dir/
done

# Protein related files
$wgetcmd $ftproot/Proteins

# GO/PO related files
$wgetcmd $ftproot/Ontologies/Gene_Ontology
$wgetcmd $ftproot/Ontologies/Plant_Ontology

# Polymorphism related files
$wgetcmd $ftproot/Polymorphisms

# Microarray related files
$wgetcmd $ftproot/Microarrays

# Protocols
$wgetcmd $ftproot/Protocols
