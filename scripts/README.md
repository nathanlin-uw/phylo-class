This is a folder where I will keep all my scripts. These scripts should be run in this folder. The scripts starting with the number 0 are for the BUSCO genes analyses, while the integer-starting scripts are for the individual locus analyses.

# Individual genes dataset 
1. The first script downloads genome assemblies from NCBI and pulls out the nucleotide sequence files of each, placing them in the ../raw_data/ folder.
	- `bash 1_data_downloading.sh`

2. The second script declares the genes and species we'll use, and sets up folders for each gene and blast databases for each species in the blast/ folder. It then searches the genome databases for matches to our reference gene sequences, placing the best matches for each gene in tsv files in their respective `../blast/[gene]_hits/` folder. 
	- `bash 2_blast_setup.sh`
	- This may take ~15 minutes

BETWEEN THESE STEPS: for each gene, manually create a compiled all-species .tsv file with the species name, contig/scaffold identifier, match start index, and match end index in `/blast/[gene]_hits/[gene]_hits_compiled.tsv` 
	- Look for lowest e value (2nd-last col), highest percent identity (3rd col), and highest alignment length (4th col)
	- Forward or reverse (depends on start and end index) doesn't matter we'll fix it in the next step.

3. The third script takes a gene name, looks for the `[gene]_hits_compiled.tsv` file, then iterates and parses through the file, running the blastdbcmd command to pull out the specified best match for each species and placing it in the `../blast/[gene]_seqs/[gene]_[species].fna` fasta file. It will reverse complement sequences that are on the minus strand of the reference genomes.
	- `bash 3_seqs_from_hits.sh 28s`

4. The fourth script puts the gene trees created by RAxML into a single .tre file for use with ASTRAL-IV later.

# BUSCO genes dataset
Follow the alphabetical order: `0a_investigating_busco_genes.R` is for digging in to taxon representation for the extracted BUSCO genes, `0b_subsetting_busco_genes.sh` is for pulling out genes for various levels of taxon representation, `0ca_make_full_supermatrix.R` and `0cb_make_smaller_supermatrix.R` both make a supermatrix but differ in the dataset size (956 vs 238 genes), `0d_raxml_gene_trees.sh` runs RAxML on all alignments of the BUSCO genes, and `0e_compile_raxml_gene_trees.R` puts all of the RAxML gene trees into a .tre file for ASTRAL-IV.
