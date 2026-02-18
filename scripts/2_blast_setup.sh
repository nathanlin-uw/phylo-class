#!/bin/bash

# Requires a conda environment with NCBI's blast package
	# conda activate blast_env

# These are the genes we are going to use, along with the reference sequence of each 
declare -A genes=( 
	["its2"]="its2_ricinus.fna"
	["its1"]="its1_rubicundus.fna"
	["18s"]="18s_affinis.fna"
	["28s"]="28s_rubicundus.fna"
)

# Sets up the folders for each gene
for gene in "${!genes[@]}"; do
	mkdir ../blast/"$gene"_hits
	mkdir ../blast/"$gene"_seqs
done

# These are the species we will use
species_list=( 
	"a_americanum" 
	"d_variabilis" 
	"h_longicornis" 
	"i_hexagonus" 
	"i_inopinatus" 
	"i_pacificus" 
	"i_persulcatus"
	"i_ricinus"
	"i_scapularis"
	"o_turicata"
	"r_sanguineus"
)


# Making blast databases for each species
for species in "${species_list[@]}"; do
	makeblastdb -in ../raw_data/"$species".fna -dbtype nucl -parse_seqids -out ../blast/db_"$species"/db_"$species"
done

# Debugging checkpoint
echo "Finished making blast databases."

# Running blastn to find matches in each genome database for each gene
for gene in "${!genes[@]}"; do
	for species in "${species_list[@]}"; do
		blastn -query ../blast/reference_seqs/"${genes[$gene]}" -db ../blast/db_"$species"/db_"$species" -out ../blast/"$gene"_hits/"$species".out.tsv -outfmt 6
	done
done

# Success confirmation message
echo "All done!"
