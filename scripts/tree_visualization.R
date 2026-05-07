library(ape)

# setwd("//wsl.localhost/Ubuntu/home/ntlin/phylo-class/")

non_ixodes <- c("A_americanum", "D_variabilis", "H_longicornis", "O_turicata", "R_sanguineus")

## Looking at our single locus trees with bootstrap support
library(phangorn)
# Using phangorn::plotBS, only showing labels with greater than 0.7 

par(mfrow=c(1,3))
# Pitiful bootstrap support for everything except monophyly of prostriata vs metastriata, monophyly of Ixodes subgenus, clade with I_inopinatus, I_ricinus, and I_pacificus
  # Even the generic relationships within Metastriata are cannot be inferred with this
# best_tree_18s <- read.tree("results/renamed_aligns_raxml/18s_mafft_align.fna.raxml.bestTree")
# rooted_best_18s <- root(best_tree_18s, "O_turicata")
# bs_trees_18s <- read.tree("results/renamed_aligns_raxml/18s_mafft_align.fna.raxml.bootstraps")
# plotBS(rooted_best_18s, bs_trees, type="phylogram", cex=1)
# only_ixodes_18s <- drop.tip(rooted_best_18s, c(non_ixodes))
# plotBS(only_ixodes_18s, bs_trees, type="phylogram", cex=0.5, p=0.7)

# Pitiful bootstrap support for everything except monophyly of prostriata vs metastriata, monophyly of Ixodes subgenus
  # Even the generic relationships within Metastriata are cannot be inferred with this
# best_tree_28s <- read.tree("results/renamed_aligns_raxml/28s_mafft_align.fna.raxml.bestTree")
# rooted_best_28s <- root(best_tree_28s, "O_turicata")
# bs_trees_28s <- read.tree("results/renamed_aligns_raxml/28s_mafft_align.fna.raxml.bootstraps")
# plotBS(rooted_best_28s, bs_trees, type="phylogram", cex=1)
# only_ixodes_28s <- drop.tip(rooted_best_28s, c(non_ixodes))
# plotBS(only_ixodes_28s, bs_trees, type="phylogram", cex=0.5, p=0.7)

# ITS2 only has Ixodes, pitiful bootstrap support for everything here
# best_tree_its2 <- read.tree("results/renamed_aligns_raxml/its2_mafft_align.fna.raxml.bestTree")
# bs_trees_its2 <- read.tree("results/renamed_aligns_raxml/its2_mafft_align.fna.raxml.bootstraps")
# plotBS(best_tree_its2, bs_trees, type="phylogram", cex=1)

par(mfrow=c(1,1))
raxml_its2_tree <- read.tree("results/renamed_aligns_raxml/its2_mafft_align.fna.raxml.support")
plot(raxml_its2_tree, no.margin=TRUE)
nodelabels(text=raxml_its2_tree$node.label, frame="circle")


# Resolution is bad here 
  # There is good support 99 and 89 for monophyly of Ixodes and subgenus Ixodes
  # 93 for I believe ricinus and inopinatus but it's really hard to make out
raxml_18s_tree <- read.tree("results/renamed_aligns_raxml/18s_mafft_align.fna.raxml.support")
plot(raxml_18s_tree, no.margin=TRUE)
nodelabels(text=raxml_18s_tree$node.label, frame="circle")
only_ixodes_18s <- drop.tip(raxml_18s_tree, c(non_ixodes))
plot(only_ixodes_18s, no.margin=TRUE)
nodelabels(text=only_ixodes_18s$node.label, frame="circle")

# We see good support for persulcatus being off on its own too
par(mfrow=c(1,2))
raxml_28s_tree <- read.tree("results/renamed_aligns_raxml/28s_mafft_align.fna.raxml.support")
plot(raxml_28s_tree, no.margin=TRUE)
nodelabels(text=raxml_28s_tree$node.label, frame="circle")
only_ixodes_28s <- drop.tip(raxml_28s_tree, c(non_ixodes))
plot(only_ixodes_28s, no.margin=TRUE)
nodelabels(text=only_ixodes_28s$node.label, frame="circle")


## Looking at MrBayes output tree
# Going to use treeio to read in the consensus tree rather than ape
library(treeio)
library(ggtree)
mrbayes_tree_28s <- read.mrbayes("mrbayes/28s_mafft_align_mb.nex.con.tre")
ggtree(mrbayes_tree_28s) +
  geom_tiplab() +
  geom_text2(aes(subset=!isTip, label=round(as.numeric(prob), 2)), hjust=-0.1) + 
  theme_tree2()



#### MULTI LOCUS THINGS

## Astral + Concatenation species tree 
# Astral first
par(mfrow=c(1,1))
species_tree <- read.tree("5_species_tree_astral4.tre")
plot(species_tree)

sp_tree_rooted <- root(species_tree, outgroup="o_turicata", resolve.root=TRUE)
plot(sp_tree_rooted)

sp_tree_only_ixodes <- drop.tip(sp_tree_rooted, c("o_turicata", "h_longicornis", "a_americanum", "d_variabilis", "r_sanguineus"))
plot(sp_tree_only_ixodes)

# We want branch support values, compare to concatenation
# Astral with support
collapsed_input_sp_tree <- read.tree("5_species_tree_astral4_collapsed_input.tre")
plot(collapsed_input_sp_tree, no.margin=TRUE)
nodelabels(text=collapsed_input_sp_tree$node.label, frame="circle")

# Concatenation with support
concatenated_tree <- read.tree("2ba_smaller_supermatrix/smaller_supermatrix.fna.raxml.support")
plot(root(concatenated_tree, outgroup="o_turicata"), no.margin=TRUE)
nodelabels(text=concatenated_tree$node.label, frame="circle")



## Taking a look at some RAxML gene trees
par(mfrow=c(2,3))
gene_tree_one <- read.tree("./3_busco_sc_gene_trees_raxml_w_bs/27301at6933_mafft_align.fna.raxml.support")
plot(root(gene_tree_one, outgroup="o_turicata"), no.margin=TRUE)
nodelabels(text=gene_tree_one$node.label, frame="circle")

gene_tree_two <- read.tree("./3_busco_sc_gene_trees_raxml_w_bs/17500at6933_mafft_align.fna.raxml.support")
plot(root(gene_tree_two, outgroup="o_turicata"))
nodelabels(text=gene_tree_two$node.label, frame="circle")

gene_tree_three <- read.tree("./3_busco_sc_gene_trees_raxml_w_bs/9922at6933_mafft_align.fna.raxml.support")
plot(root(gene_tree_three, outgroup="o_turicata"))
nodelabels(text=gene_tree_three$node.label, frame="circle")

gene_tree_four <- read.tree("./3_busco_sc_gene_trees_raxml_w_bs/27237at6933_mafft_align.fna.raxml.support")
plot(root(gene_tree_four, outgroup="o_turicata"))
nodelabels(text=gene_tree_four$node.label, frame="circle")

gene_tree_five <- read.tree("./3_busco_sc_gene_trees_raxml_w_bs/42at6933_mafft_align.fna.raxml.support")
plot(root(gene_tree_five, outgroup="o_turicata"))
nodelabels(text=gene_tree_five$node.label, frame="circle")

gene_tree_six <- read.tree("./3_busco_sc_gene_trees_raxml_w_bs/8534at6933_mafft_align.fna.raxml.support")
plot(root(gene_tree_six, outgroup="o_turicata"))
nodelabels(text=gene_tree_six$node.label, frame="circle")

par(mfrow=c(1,1))



