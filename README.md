araport-contrib
===============

Data files (and scripts used to generate these files) for the AIP Intermine, JBrowse and GBrowse2 installations

Shell scripts used to generate data files rely on methods available at the following github repository: [tanghaibao/jcvi](https://github.com/tanghaibao/jcvi>).

### Setting up the data area

	### choose location to download all relevant data files from TAIR FTP
	### for this project, the data root is $AIP_HOME=/usr/local/projects/AIP
	$ AIP_HOME=/usr/local/projects/AIP && cd $AIP_HOME
	$ mkdir -p DataProviders/TAIR && cd DataProviders/TAIR
	
	### clone the araport-contrib repo
	$ git clone https://github.com/Arabidopsis-Information-Portal/araport-contrib.git
	
	### download all TAIR data
	$ ./download_tair_data.sh > download_tair.log 2>&1
	
	### adjust the ${AIP_HOME} environment variable by editing araport.env
	$ vim araport.env
	
	### prepare all the necessary fasta files: genome, CDS, AA, flanking
	### they are not under version control because of file size limitations
	$ ./prepare_TAIR10_fasta.sh > prepare_fasta.log 2>&1
	
	### modifications to GFF3 files and GO annotation stored in this repo 
	### therefore, there is no need to run the GFF3 preparation script
	
Once the above setup process is complete, follow instructions for installing and loading data into [JBrowse](https://github.com/Arabidopsis-Information-Portal/jbrowse-contrib/blob/master/README.md) and [GBrowse2](https://github.com/Arabidopsis-Information-Portal/gbrowse2-contrib/blob/master/README.md) from their respective repos.
