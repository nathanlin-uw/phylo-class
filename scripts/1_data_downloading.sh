#!/bin/bash

# This requires that you have a conda env called ncbi_datasets already set up with that package. 
	# conda activate ncbi_datasets

# This also requires that we have a folder called raw_data already in existence (in the main directory)

# Making an associative array (pretty much a dictionary) with species and accession IDs for their genomes
declare -A genomes=( 
	["a_americanum"]="GCF_052857255.1"  
	["d_variabilis"]="GCF_050947875.1"
	["h_longicornis"]="GCF_048455015.1"
	["i_hexagonus"]="GCA_964199285.2"
	["i_inopinatus"]="GCA_964198085.1"
	["i_pacificus"]="GCA_964199305.2"
	["i_persulcatus"]="GCA_965286795.1"
	["i_ricinus"]="GCA_043645445.1"
	["i_scapularis"]="GCF_016920785.2"
	["o_turicata"]="GCF_037126465.1"
	["r_sanguineus"]="GCF_013339695.2" 
)

# Make a temporary zip files storage
mkdir temp_zips

# Download zip files
for species in "${!genomes[@]}"; do
	datasets download genome accession "${genomes[$species]}" --include genome --filename ./temp_zips/"${species}".zip
done

# Process zip files and put their .fna files in raw_data
for zip_name in ./temp_zips/*.zip; do
	unzip -o "$zip_name" -d ./temp_zips
	mv ./temp_zips/ncbi_dataset/data/*/*.fna ../raw_data/"${zip_name:12:-4}".fna
done

# Delete the temporary zip files storage
rm -rf temp_zips

# Just a confirmation
echo "Successfully downloaded and extracted all .fna files!"
