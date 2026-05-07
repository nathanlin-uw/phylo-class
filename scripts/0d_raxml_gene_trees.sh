#!/bin/bash

# Change these each time
DATADIR="../2_aligned_filtered_busco_sc_genes"
run_description="all_genes"

mkdir ../3_busco_sc_gene_trees_raxml_w_bs/

# We'll store the ones we already did here
completed_filenames="../3_busco_sc_gene_trees_raxml_w_bs/${run_description}_log_completed_files.txt"
touch "$completed_filenames"

for file in "$DATADIR"/*; do
        # Check to see if we have run RAxML on the file already
               # Exit status of 0 means true, and if there is a match the exit status will be 0
        if grep "$file" "$completed_filenames"; then
               # Do nothing
                echo "Already finished ${file}"
        else
               # Run RAxML on the file and putting the results in our results folder
                raxml-ng --all --msa $file --bs-trees 100 --model auto --data-type DNA
                mv ${file}**raxml** ../3_busco_sc_gene_trees_raxml_w_bs
                # Add the file to the completed filenames record
                echo "$file" >> "$completed_filenames"
        fi
done
