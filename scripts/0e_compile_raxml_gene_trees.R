library(ape)
library(phangorn)

# Set working directory to RAxML outputs folder
# setwd("//wsl.localhost/Ubuntu/home/ntlin/phylo-class/3_busco_sc_gene_trees_raxml_w_bs")

# List the best tree with support values files from RAxML, the $ means it's the end of the string
gene_tree_files <- list.files(pattern="\\.raxml.support$") 

# Set up a list and make it a multiPhylo object
all_gene_trees <- list()
class(all_gene_trees) <- "multiPhylo"

# Iterate through gene tree files and add them to the combined object
for (i in 1:length(gene_tree_files)) {
	all_gene_trees[[i]] <- read.tree(gene_tree_files[i])
}

# Write these to a .tre file
write.tree(all_gene_trees, file="../4_all_filtered_busco_sc_gene_trees.tre")


## For ASTRAL-IV, I want to feed it trees where nodes with <70% support are collapsed
collapsed_trees <- list()

for (i in 1:length(all_gene_trees)) {
  # The function di2multi collapses only based on branch length not node label
  # So we need to set branch length to 0 if node label is less than 0.7
  current_tree <- all_gene_trees[[i]]
  # Pull out the low support nodes
  low_support_nodes <- which(as.numeric(current_tree$node.label) < 0.7)
  node_indices <- low_support_nodes + length(current_tree$tip.label)
  # Identify edges they are associated with
  edges_to_collapse <- which(current_tree$edge[, 2] %in% node_indices)
  # Set those edge lengths to 0
  current_tree$edge.length[edges_to_collapse] <- 0
  # Collapse with ape's di2multi and add that to collapsed_trees
  collapsed_trees[[i]] <- di2multi(current_tree, tol=1e-10)
}

# Write these to a second .tre file 
write.tree(collapsed_trees, file="../4b_all_filtered_busco_gene_trees_collapsed.tre")
