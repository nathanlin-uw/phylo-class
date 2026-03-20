This is the notebook log for my Spring 2026 phylogenetics class tick genomes phylogeny project.

### Introduction and taxon selection ###
I will be using the publicly-available genomes of 11 tick species from the National Center of Biotechnology Information database, focusing on the genus Ixodes. Specifically, I will use the arachnid lineage BUSCO genes to construct the phylogeny.

I will use the following genera and species: 
- Ixodes: 
    - I. pacificus (https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_964199305.2/)
    - I. scapularis (https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_016920785.2/)
    - I. persulcatus (https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_965286795.1/)
    - I. ricinus (https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_043645445.1/)
    - I. inopinatus (https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_964198085.1/)
    - I. hexagonus (https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_964199285.2/)
- Haemaphysalis longicornis (https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_048455015.1/)
- Amblyomma americanum (https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_052857255.1/)
- Dermacentor variabilis (https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_050947875.1/)
- Rhipicephalus sanguineus (https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_013339695.2/)
- Ornithodoros turicata (https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_037126465.1/)

The generic tree topology according to Beati and Klompen (2019) should look like (Ornithodoros + (Ixodes + (Haemaphysalis + (Amblyomma + (Rhipicephalus + Dermacentor))))). 
- Lorenza Beati, Hans Klompen. 2019. Phylogeography of Ticks (Acari: Ixodida). Annual Review Entomology. 64:379-397. https://doi.org/10.1146/annurev-ento-020117-043027

### Data acquisition ###
I used the NCBI datasets package to download everything. It was available through conda, with the installation and usage code below. 

```
# Creating and activating a conda environment for the dataset downloading
conda create -n ncbi_datasets
conda activate ncbi_datasets
# Installing NCBI's datasets package
conda install -c conda-forge ncbi_datasets-cli
```
In the data/ folder:
`datasets download genome accession [assembly_ID] --include genome`

I unzipped the zip folders and just kept the .fna genome sequences files.

### Quality control ###
I had wanted to use BUSCO (Benchmarking Universal Single-Copy Orthologs) to evaluate the completeness of each genome. 

Installing BUSCO:
```
conda create -n busco_env -c conda-forge -c bioconda busco=6.0.0 sepp=4.5.5
conda activate busco_env
```

To see what datasets are available:
`busco --list-datasets`
It looks like we can use acari_odb12 (it supposedly has 1957 genes).

In the GCA_964199305.2/ folder (corresponds to I. pacificus):
`busco -i GCA_964199305.2_IXPA_v2_genomic.fna -l acari -m genome -o ~/phylo-class/data/i_pacificus_genome/i_pacificus_busco_acari`

I got this error message: 
```
anaconda3/envs/busco_env/lib/python3.12/multiprocessing/resource_tracker.py:279: UserWarning: resource_tracker: There appear to be 7 leaked semaphore objects to clean up at shutdown
  warnings.warn('resource_tracker: There appear to be %d '
```
Apparently this means that BUSCO was abnormally stopped due to insufficient memory. I had to do wsl --shutdown in the PowerShell since I was getting a WSL Catastrophic Error with Ubuntu crashing.
I had tried running it with fewer cores and everything but I think the fact that these genomes are so large makes BUSCO exceed the 12 gigabyte RAM I have to work with.

In any case these are published assemblies and for the non-Ixodes taxa I had picked the ones with a public >89% BUSCO score on NCBI.
BUSCO scores were not published for many of the Ixodes species, though.

### Simplifying my data ###
The genomes are a bit too large, so I am just going to try the ITS2, ITS1, 18S, and 28S nuclear genes for this project.
- For background on marker selection I read Cruickshank 2002 (https://doi.org/10.11158/saa.7.1.1)

I have a reference ITS2 sequence from I. ricinus for BLASTing later from https://www.ncbi.nlm.nih.gov/nuccore/FN296276.1. I pulled the ITS2 sequence out and put it in the fasta its2_ricinus.fna.
I did the same for ITS1 from I. rubicundus (https://www.ncbi.nlm.nih.gov/nuccore/KY457497.1) and also 28S from I. rubicundus (same link https://www.ncbi.nlm.nih.gov/nuccore/KY457497.1)
For 18S I used I. affinis (https://www.ncbi.nlm.nih.gov/nuccore/L76350.1)

I created a new conda environment with NCBI's blast package, created a folder called blast/, and created a subfolder reference_seqs/ for the ITS2, ITS1, 18S, and 28S blast queries.
All next steps will be in blast/.

Made a folder for the resulting hits then another folder for the final sequences for each gene:
`mkdir its2_hits` `mkdir its2_seqs` etc

For each species (this is I. pacificus with ITS2 for example):
1. Use the genome fasta to make the blast database in the designated folder:
`makeblastdb -in ../raw_data/i_pacificus.fna -dbtype nucl -parse_seqids -out ./db_i_pacificus/db_i_pacificus`
2. Run blastn to find matches in the genome database to the reference gene sequence:
`blastn -query ./reference_seqs/its2_ricinus.fna -db ./db_i_pacificus/db_i_pacificus -out ./its2_hits/its2_hits_i_pacificus.out -outfmt 6`
3. Inspect the output and find the highest-scored hit based on maximizing alignment length and minimizing e-value
- Note the subject ID and the alignment start and end indices (columns 2, 9, and 10)
- Forward or reverse direction won't matter since we will reverse complement any that need reverse complementing with seqkit later on (see the script below)
- There is an explanation for the BLASTn output here: https://www.metagenomics.wiki/tools/blast/blastn-output-format-6
`less ./its2_hits/its2_hits_i_pacificus.out`
4. Use blastdbcmd to pull out the sequence using the subject ID and start/end indices
`blastdbcmd -db ./db_i_pacificus/db_i_pacificus -entry CAXMZB020025033.1 -range 2873-3968 -out ./its2_seqs/its2_i_pacificus.fna`

REPEATING FOR EACH SPECIES AND EACH GENE:
Making the blastdbs:
- Turns out you can pull out substrings of the variable you're iterating over (i'll use this for species names) with `${var_name_or_string:start_index_end_index_exclusive}`
- makeblastdb also creates the output directory for you if you don't have it already made
`for file_name in ../raw_data/*; do makeblastdb -in ../raw_data/$file_name -dbtype nucl -parse_seqids -out ./db_${file_name:12:-4}/db_${file_name:12:-4}; done`
Running blastn (for ITS-2, would need to replace the reference seq and output names for other genes):
- First had to make the its2 directory
`for file_name in ../raw_data/*; do blastn -query ./reference_seqs/its2_ricinus.fna -db ./db_${file_name:12:-4}/db_${file_name:12:-4} -out ./its2_hits/its2_hits_${file_name:12:-4}.out -outfmt 6; done`

ONE ISSUE:
I cannot get BLAST to pull out a matching ~500bp sequence for ITS1 and a matching ~600bp sequence for ITS2 for most species. I've played with the -word_size parameter for blastn, but nothing has worked (perhaps the sequences are just too divergent for the BLAST algorithm? it's really odd). I will just pull out the longest hit I can get and include the partial data.

### LITTLE HICCUP HERE (Starting the Scriptification) ###
My git system broke I think something got corrupted somehow but I deleted the repository only to realize that oh wait I have all the data there and it's not on the GitHub so I will need to do everything again. So it's time to learn how to do bash scripting so I can make this a smoother process. Thank goodness I have some degree of reproducibility already.

Success! I wrote a script that I can use to redownload everything and get the .fna sequences into the `raw_data/` folder. It'll be in the `scripts/` folder, called `1_data_downloading.sh`.

Miscellaneous script writing things:
	- First line is always `#!/bin/bash`
	- Referencing a variable always use quotes and dollar sign `"$var_name"`
	- Arrays in bash are like ( "item 1" "item 2" "etc" )
	- Remember the `for item in list; do [something]; done`
	- You can have associative arrays (dictionaries) but you have to declare them first
		- `declare -A dict_name=( ["key1"]="value1" ["key2"]="value2" )`
		- To iterate through these use this:
			- `for key in "${!dict_name[@]}"; do ...; done`
			- Access keys with `"$key"` and values with `"${dict_name[$key]}"`
	- `unzip -o file.zip -d ./dir_to_extract_to`
		- -o for overwriting everything

I also made two scripts for setting up the blast folder structure, producing best genome sequence matches for the reference sequences, and after an intermediate step, pulling those best matches out to fasta files and compiling them. These are titled `2_blast_setup.sh` and `3_seqs_from_hits.sh`. 

After all these are done, we will have gene sequences in the `blast/[gene]_seqs/` folder! Note that there will be a `combined_[gene].fna` file with all the sequences inside for each gene.

### Alignment with MAFFT ###
I will be aligning the 28s sequences first.

I am using MAFFT, which uses the Fast Fourier Transform approach to infer homologous regions between sequences to reduce comparisons and time needed for sequence alignment. It assumes at the very least that the input sequences are homologous.

I ran MAFFT with the \*G-INS-i accuracy-oriented, iterative refinement method incorporating global pairwise alignment because I had fewer than 200 sequences (only 11). I chose \*G-INS-i instead of \*L-INS-i or \*E-INS-i because the sequences were of similar length and did not contain large unalignable regions. By default, the local pairwise alignment gap opening penalty was -2.00, the local pairwise alignment offset value was 0.1, and the local pairwise alignment gap extension penalty was -0.1. 

(In the alignments/ folder, with the alignments_env conda environment containing MAFFT active)
`conda activate alignments_env` 
`mafft --globalpair --maxiterate 1000 ../blast/28s_seqs/combined_28s.fna > 28s_mafft_align.fna`

For the ITS1 and ITS2 alignments I use the \*L-INS-i method because the available sequences are no longer of similar length. If these are an issue later I will just exclude them.
`mafft --localpair --maxiterate 1000 ../blast/its1_seqs/combined_its1.fna > its1_mafft_align.fna`

(Finish this later) I can scriptify this in `4_align_seqs.sh`! This would run MAFFT, MUSCLE, and ClustalW (perhaps even CACTUS later), and put their alignments in the alignments/ folder. 

### Distance and Parsimony Trees in R ###
I used the ape and phangorn packages in R to make a neighbor joining and maximum parsimony tree for each of the genes. 

Setup: For both trees, I used the `fasta2dnabin` function to convert the fasta files to a DNAbin object, then used that DNAbin object to create a matrix of distances with the `dist.dna` function. For the distance tree, I used the "TN93" model option for the flexibility of differential transition-transversion rates, heterogeneous base frequencies, and between-site substitution rate variation, while for the parsimony tree, I used the "raw" option for p-distances. For the parsimony tree, I also converted the DNAbin object to a phyDat object with `as.phyDat`.

Tree making: I used the `nj` function to create the neighbor-joining tree and the initial tree for the parsimony tree search start. For the maximum parsimony tree, I used the `optim.parsimony` function with the phangorn phyDat object.

I made the trees for each gene individually first (I will combine them later). Neither tree worked for ITS1 because there was too much missing data across the sequences. The 18S and 28S genes produced the same trees in all instances, and for those genes, both the neighbor joining and maximum parsimony trees wrongly treated Ixodes as the outgroup with Ornithodoros the most ancestral taxon of a clade with all of the other genera. For the ITS2 distance tree, I. hexagonus was not part of the outgroup, while it appeared as an outgroup in the maximum parsimony tree.

### Maximum Likelihood for Gene Trees ###
I used RAxML-NG version 2.0.0 and IQ-TREE version 3 to make maximum-likelihood trees for each gene.

To set this up, I made a results directory and the directories "iqtree" and "raxml" inside. I also had to remove the colons from my fasta files because they interfere with RAxML. To do this I did the following in the alignments\ folder: `for file in *.fna; do sed -i "s/://g"; done`

(In the alignments folder)
To run RAxML, I did `raxml-ng --msa its2_mafft_align.fna --model auto --data-type DNA` for each alignment.
After the runs, I moved the files to the `results/` folder with `for file in *.raxml.*; do mv $file ../results/raxml; done`.
To run IQ-TREE, I did `iqtree3 -s 18s_mafft_align.fna` for each alignment.
After the runs, I moved the files to the `results/` folder with `for file in *.fna.*; do mv $file ../results/iqtree; done`.

RAxML and IQ-TREE both now have automatic model selection. 
