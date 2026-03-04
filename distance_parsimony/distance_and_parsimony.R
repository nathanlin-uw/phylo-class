# Load in libraries
library("ape")
library("adegenet")
library("phangorn")

library("glue")

# Set working directory
# setwd("//wsl.localhost/Ubuntu/home/ntlin/phylo-class/distance_parsimony/")

### DISTANCE TREE WITH APE ###

# Making a function for plotting a NJ tree for a specific gene
plot_nj <- function(gene) {
  # Load in my sample data (it throws a warning for wrong file extension but .fna works fine)
  dnabin <- fasta2DNAbin(file=glue("../alignments/{gene}_mafft_align.fna"))
  
  # Compute genetic distances with the TN93 model
  # We want the flexibility of differential transition-transversion rates, heterogeneous base frequencies, and between-site substitution rate variation
  D_matrix <- dist.dna(dnabin, model="TN93")
  
  # Make Neighbor Joining tree
  nj_tree <- nj(D_matrix)
  
  # Ladderize and plot and title the tree
  ladderized_nj_tree <- ladderize(nj_tree)
  plot(ladderized_nj_tree, cex=0.6)
  title(glue("Neighbor Joining Tree with {gene} Gene"))
}

# Plot the 28S-based tree
plot_nj("28s") # Outgroup is Ixodes instead of Ornithodoros which isn't right

# Plot the 18S-based tree
plot_nj("18s") # Same as 28S

# Plot the ITS1-based tree
plot_nj("its1") # We get missing values here in the D matrix (there's a lot of missing data, makes sense)

# Plot the ITS2-based tree
plot_nj("its2") # Ixodes hexagonus should be the outgroup so that's not right


### PARSIMONY TREE WITH PHANGORN ###
# Making a function for plotting a NJ tree for a specific gene
plot_parsimony <- function(gene) {
  # Load in my sample data (it throws a warning for wrong file extension but .fna works fine)
  dnabin <- fasta2DNAbin(file=glue("../alignments/{gene}_mafft_align.fna"))
  # Turn it into a phangorn object
  dna_for_phangorn <- as.phyDat(dnabin)
  
  # Initial tree for the search start. Use "raw" for p-distances.
  initial_tree <- nj(dist.dna(dnabin, model="raw"))
  # Calculate and print parsimony score of this
  print(paste("Initial tree parsimony score: ", parsimony(initial_tree, dna_for_phangorn)))
  
  # Search for max parsimony tree
  parsimony_tree <- optim.parsimony(initial_tree, dna_for_phangorn)
  
  # Plot the parsimony tree
  plot(parsimony_tree, cex=0.6)
  title(glue("Maximum Parsimony Tree with {gene} Gene"))
}

# Plot the 28S-based tree
plot_parsimony("28s") # Ixodes is the otugroup AND it's paraphyletic here ahahaha that's really not right

# Plot the 18S-based tree
plot_parsimony("18s") # Same as 28S

# Plot the ITS1-based tree
plot_parsimony("its1") # We get missing values here in the D matrix (there's a lot of missing data, makes sense)

# Plot the ITS2-based tree
plot_parsimony("its2") # Ixodes hexagonus made it to the outgroup here but I. scapularis was not grouped with the others
