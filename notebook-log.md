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
The version of BUSCO I used, 6.0.0, depends on `sepp` version 4.5.5, `hmmsearch` version 3.4, `bbtools` version 38.90, `miniprot_index` version 0.18-r281, and `miniprot_align` version 0.18-r281.

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

UPDATE (way later in April lol): I got BUSCO going on my lab's workstation since it has a lot more computational capability than my laptop. I copied the raw genome sequences from my laptop over to the workstation with `scp`, then installed BUSCO's version 6.0.0 with conda, and it was off to the races.

To run BUSCO on each genome fasta in the `raw_data/` folder, I used the following command:
`for taxon in "a_americanum" "d_variabilis" "h_longicornis" "i_hexagonus" "i_inopinatus" "i_pacificus" "i_persulcatus" "i_ricinus" "i_scapularis" "o_turicata" "r_sanguineus"; do busco -i "${taxon}.fna" -l acari -m genome -c 20 -o "../busco_${taxon}_acari"; done`
This runs BUSCO on every genome assembly and makes a new output folder for each. I could also have used `for file in *.fna` with `"${file:0:-4}"` to take out the .fna later on.

From here, I gathered the summary statistics files for each run with the command `mkdir busco_0_summaries; for dirname in busco_*_acari; do cp "${dirname}/short_summary.specific.acari_odb12.${dirname}.txt" "busco_0_summaries/${dirname}.txt"; done`.

Completeness scores with the acari_odb12 lineage were as follows: A. americanum (97.6%), D. variabilis (99.8%), H. longicornis (98.4%), I. hexagonus (88.5%), I. inopinatus (96.8%), I. pacificus (89.1%), I. persulcatus (82.6%), I. ricinus (92.1%), I. scapularis (99.2%), O. turicata (98.0%), and R. sanguineus (97.3%). Ixodes inopinatus had only 441 complete single copy genes, oddly, while the other taxa all had greater than 1500, so I may have to remove it for some parts of the analysis. The number of scaffolds of each assembly varied greatly, from under 1000 in A. americanum/D. variabilis/H. longicornis/I. scapularis/O. turicata, to 2300 in R. sanguineus, 25000 in Ixodes ricinus, and over 90000 in I. hexagonus/I. inopinatus/I. pacificus/I. persulcatus.

After the summary statistics, I used these commands to pull out all of the single copy BUSCO genes and compile them: 
1. Set up file system (in `nathan_ticks_phylo`, makes one new folder with a subfolder for each species inside): `mkdir busco_1_single_copy_genes; for dirname in busco_*_acari; do mkdir "busco_1_single_copy_genes/${dirname:6:-6}"; done`
2. Copy .gff files into respective species folders (in `nathan_ticks_phylo`, takes ~30 seconds): `for dirname in busco_*_acari; do for gff_file in ${dirname}/run_acari_odb12/busco_sequences/single_copy_busco_sequences/*.gff; do cp "${gff_file}" "./busco_1_single_copy_genes/${dirname:6:-6}/"; done; done`
3. Convert .gff to .fna with gffread (in `busco_1_single_copy_genes/`, first conda install gffread, this step will take ~100 minutes if we have ~18,000 items to get through and we convert ~3 files per second): `for species in *; do for gff_file in $species/*.gff; do gffread ${gff_file -g "../raw_data/${species}.fna" -w "${gff_file:0:-4}.fna"; done; done`
4. Relabel fasta headers and preliminary merging to get one per gene


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

(Finish this later) I can scriptify this in `4_align_seqs.sh`! This would run MAFFT, MUSCLE, and ClustalW, and put their alignments in the alignments/ folder. 

### Distance and Parsimony Trees in R ###
I used the ape and phangorn packages in R to make a neighbor joining and maximum parsimony tree for each of the genes. 

Setup: For both trees, I used the `fasta2dnabin` function to convert the fasta files to a DNAbin object, then used that DNAbin object to create a matrix of distances with the `dist.dna` function. For the distance tree, I used the "TN93" model option for the flexibility of differential transition-transversion rates, heterogeneous base frequencies, and between-site substitution rate variation, while for the parsimony tree, I used the "raw" option for p-distances. For the parsimony tree, I also converted the DNAbin object to a phyDat object with `as.phyDat`.

Tree making: I used the `nj` function to create the neighbor-joining tree and the initial tree for the parsimony tree search start. For the maximum parsimony tree, I used the `optim.parsimony` function with the phangorn phyDat object.

I made the trees for each gene individually first (I will combine them later). Neither tree worked for ITS1 because there was too much missing data across the sequences. For both the 18S and 28S genes, both the neighbor joining and maximum parsimony trees wrongly treated Ixodes as an outgroup, with Ornithodoros the most ancestral taxon of a clade with all of the other genera. Ixodes was monophyletic in the neighbor joining trees but paraphyletic in the parsimony trees. For the ITS2 distance tree, I. hexagonus was not part of the outgroup, while it appeared as an outgroup in the maximum parsimony tree.

### Maximum Likelihood for Gene Trees ###
I used RAxML-NG version 2.0.0 and IQ-TREE version 3 to make maximum-likelihood trees for each gene.

To set this up, I made a results directory and the directories "iqtree" and "raxml" inside. I also had to remove the colons from my fasta files because they interfere with RAxML. To do this I did the following in the alignments\ folder: `for file in *.fna; do sed -i "s/://g" $file; done`

(In the alignments folder)
To run RAxML, I did `raxml-ng --msa its2_mafft_align.fna --model auto --data-type DNA` for each alignment.
After the runs, I moved the files to the `results/` folder with `for file in *.raxml.*; do mv $file ../results/raxml; done`.
To run IQ-TREE, I did `iqtree3 -s 18s_mafft_align.fna` for each alignment.
After the runs, I moved the files to the `results/` folder with `for file in *.fna.*; do mv $file ../results/iqtree; done`.

RAxML and IQ-TREE both now have automatic model selection (according to Bayesian Information Criterion).
- For 18S, RAxML and IQ-TREE both selected the HKY+FE+I models, which has two parameters for transition and transversion rates, equal nucleotide frequencies, and invariant sites.
- For 28S, RAxML and IQ-TREE both selected the TIM3+FO+I+G4m model, which has substitution rates for AC=CG and AT=GT, as well as unequal base frequencies, and both a proportion of invariant sites and gamma-distributed rate heterogeneity among different sites. 
- For ITS1, RAxML selected the K81+FE+G4m model, and IQ-TREE selected the K3P+G4 model (a synonym). This model has one parameter for transitions but two different ones for the two possible types of transversions, with equal nucleotide frequencies and gamma-distributed rate heterogeneity among different sites.
- For ITS2, RAxML selected the HKY+F0+G4m model, and IQ-TREE selected the HKY+F+G4 model (also a synonym). This model has only two parameters for transition and transversion rates, with unequal nucleotide "stationary frequencies" and gamma-distributed rate heterogeneity among different sites.  

### Bayesian Inference with MrBayes ###
I used MrBayes version 3.2.7a to make Bayesian Inference trees for each gene.

First, I had to convert my alignment files from .fna to .nex (nexus format). I navigated to the alignments/ folder, then ran this code: `for file in *.fna; do seqmagick convert "$file" "${file: 0:-4}.nex" --alphabet dna; done`. To make this work, I first activated the base conda environment for Python access, and used pip to install seqmagick (`pip install seqmagick`). The {file:0:-4} means we cut off the last four spaces of the name (.fna) to be replaced with .nex, and the `--alphabet dna` bit is necessary for nexus output. After running that line, I end up with a set of `[gene]_mafft_align.nex` files to go along with each `[gene]_mafft_align.fna` original file.

In order to have branch names as species rather than contig ids/sequence ranges, I made a tab-separated mapping file `seqrange_sp_mapping.tsv` with one column being the ContigID.start-end and the other being the species name. 
I then used this chain of commands to replace the sequence ranges with species name in the nexus files: `while IFS=$'\t' read -r seqrange sp; do for file in *.nex; do sed -i "s/${seqrange}/${sp}/g" "$file"; done ; done < seqrange_sp_mapping.tsv`. 
Lastly, I removed single quotes with `for file in *.nex; do sed -i "s/'//g" $file; done`. This throws an error in MrBayes (it doesn't accept quotes in the taxon names)

My MrBayes block looked like this (saved in `mrbayes/mrbayesblock.txt`): 
begin mrbayes;
 set autoclose=yes; # automatically closes MrBayes after the run ends
 prset brlenspr=unconstrained:exp(10.0);   # branch lengths can vary freely with an exponential prior having a mean of 0.1 
 prset shapepr=exp(1.0);
 prset tratiopr=beta(1.0,1.0);
 prset statefreqpr=dirichlet(1.0,1.0,1.0,1.0);
 lset nst=2 rates=gamma ngammacat=4;
 mcmcp ngen=1000000 samplefreq=500 printfreq=1000 nruns=2 nchains=4 savebrlens=yes;
 outgroup O_turicata;
 mcmc;
 sumt;
end;

I added this block to the nexus files with this command (in `alignments/`): `for file in *.nex; do cat "$file" ../mrbayes/mrbayesblock.txt > "../mrbayes/${file:0:-4}_mb.nex"; done` 

Prior selections: branch lengths with exponential distribution having mean of 0.1 substitutions per site means we can have mostly short but possibly long branches, gamma shape parameter for rate variation between sites with exponential distribution having mean of 1 means we are assuming moderate rate heterogeneity and not going too extreme, we are picking uniform and uninformative priors for transition/transversion ratio and nucleotide frequencies/bias

Used the manual here: `https://github.com/NBISweden/MrBayes/blob/develop/doc/manual/Manual_MrBayes_v3.2.pdf`
Parameter selections: we are using the HKY model with gamma-distributed rate heterogeneity across sites and four rate categories for approximation; for MCMC we are doing default 4 chains (3 heated 1 cold), number of runs is 2 by default, print and sample frequency we can do default 1000 and 500 since we have more generations (though we can increase the frequency for more resolution later), no burn-in specification needed (the first 25% of samples from the cold chain are discarded by default).

I ran MrBayes (in `mrbayes/`) using the command `mb 28s_mafft_align_mb.nex`. 

This analysis got all of the relationships right for 28S! 


### The coalescent with ASTRAL4 ###
I chose to use ASTRAL4 rather than network methods because it is faster and less computationally-intensive, but this would run into issues if gene flow is very prevalent between these species.

ASTRAL takes a .tre file containing the set of compiled gene trees as an input, so I grabbed the RAxML gene tree results and put them into such a file with the R script `4_compile_RAxML_gene_trees.R`. The script puts the gene trees in `results/all_gene_trees.tre`.

To run ASTRAL4, in the `results/` folder, I ran the command `astral4 -i ./all_gene_trees.tre -o ./species_tree_astral4.tre`.

It completed in a heartbeat because I only had 4 genes haha. This will change when I use BUSCO genes. 

To visualize the species tree, I used the default base plot in R but I will make everything in ggtree for the final report. It originally came out with really weird tip labels (contig numbers) so I renamed everything in the original alignment so it would be consistent just species names across the genes. To do that, I made a new directory in `alignments/` called `renamed_alignments/`, then copied the .fna files in `alignments/` over with `cp *.fna renamed_alignments`, and ran `while IFS=$'\t' read -r seqrange sp; do for file in ./renamed_alignments/*.fna; do sed -i "s/${seqrange}/${sp}/g" "$file"; done; done < seqrange_sp_mapping.tsv` to change the contig numbers to species names.

After this, I ran raxml again on everything in `renamed_alignments/` a-la `raxml-ng --msa its2_mafft_align.fna --model auto --data-type DNA`, moved the results to a new subdirectory of `results/` called `renamed_aligns_raxml` using the command `for file in *.raxml.*; do mv $file ../../results/renamed_aligns_raxml; done`, ran the R script `4_compile_RAxML_gene_trees.R` on the new alignments (overwriting the previous combined gene trees file), and ran ASTRAL4 again with the same command, `astral4 -i ./all_gene_trees.tre -o ./species_tree_astral4.tre`. When visualizing with R, I used the ape package's read.tree and root functions, with `species_tree <- read.tree("species_tree_astral4.tre")`, `sp_tree_rooted = root(species_tree, outgroup="O_turicata", resolve.root=TRUE)`, and finally the base R plot function. 

The branch lengths here were very problematic, with Ixodes hexagonus coming out far away from the rest of the Ixodes. Dermacentor and Amblyomma came out as sister taxa again, and it seems like there is major polytomy for the relationships between Ixodes hexagonus and the non-Ixodes taxa, even the outgroup O_turicata. I think there's just a lot of missing data here making the branch lengths and lack of resolution an issue.
