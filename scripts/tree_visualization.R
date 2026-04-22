library(ape)

# setwd("//wsl.localhost/Ubuntu/home/ntlin/phylo-class/results")

species_tree <- read.tree("species_tree_astral4.tre")
plot(species_tree)

sp_tree_rooted = root(species_tree, outgroup="O_turicata", resolve.root=TRUE)
plot(sp_tree_rooted)
