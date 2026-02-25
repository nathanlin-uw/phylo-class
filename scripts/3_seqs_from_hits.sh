#!/bin/bash

# This requires that you are in the blast_env conda environment with seqkit and blast downloaded
	# conda activate blast_env

# Grab the first (and only) positional argument
selected_gene="$1" # 28s, its2

echo "Acknowledging selection of ${selected_gene}"

hits_tsv="../blast/${selected_gene}_hits/${selected_gene}_hits_compiled.tsv"
destination_path="../blast/${selected_gene}_seqs"

echo "Paths set successfully"

# This lets me read the tab-separated file line by line (specify the file after done with the <)
while IFS=$'\t' read -r species identifier start end notes; do
	echo "Working with ${species} now"
	# This checks whether the match was on the minus strand (start index is greater than end index)
	if [[ "$start" -gt "$end" ]]; then 
		echo "This one's opposite"; 
		# I'll just swap the indices so the command still works
		placeholder="$end"; end="$start"; start="$placeholder"; 
		# Blastdb command saves the sequence to an intermediate pre-reverse complement file
		blastdbcmd -db "../blast/db_${species}/db_${species}" -entry "$identifier" -range "${start}-${end}" -out "${destination_path}/${selected_gene}_${species}_needs_rc.fna"
		# Reverse complement the sequence
		seqkit seq -t dna -r -p "${destination_path}/${selected_gene}_${species}_needs_rc.fna" -o "${destination_path}/${selected_gene}_${species}.fna"
		# Delete the intermediate file
		rm "${destination_path}/${selected_gene}_${species}_needs_rc.fna"
	else
		# The normal case, no need to reverse complement anything
		blastdbcmd -db "../blast/db_${species}/db_${species}" -entry "$identifier" -range "${start}-${end}" -out "${destination_path}/${selected_gene}_${species}.fna"
	fi
done < "$hits_tsv"

# Finally, makes a combined fasta with every species' sequence inside
rm "${destination_path}/combined_${selected_gene}.fna"
cat "${destination_path}"/*.fna > "${destination_path}/combined_${selected_gene}.fna"

echo "All done!"

