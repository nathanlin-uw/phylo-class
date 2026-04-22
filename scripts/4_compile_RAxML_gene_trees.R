library(ape)
library(phangorn)

# Set working directory to RAxML outputs folder
# setwd("//wsl.localhost/Ubuntu/home/ntlin/phylo-class/results/raxml")

# List the best tree files from RAxML, the $ means it's the end of the string
gene_tree_files <- list.files(pattern="\\.raxml.bestTree$") 

# Set up a list and make it a multiPhylo object
all_gene_trees <- list()
class(all_gene_trees) <- "multiPhylo"

# Iterate through gene tree files and add them to the combined object
for (i in 1:length(gene_tree_files)) {
	all_gene_trees[[i]] <- read.tree(gene_tree_files[i])
}

# Write these to the .tre file in the results/ folder
write.tree(all_gene_trees, file="../all_gene_trees.tre")
