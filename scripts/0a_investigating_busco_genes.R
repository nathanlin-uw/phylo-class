# Loading things
library(dplyr)
library(stringr)

# Setting working directory
# setwd("//wsl.localhost/Ubuntu/home/ntlin/phylo-class/")

# Read in the tsv
raw_busco_genes <- read.table("0b_busco_genes_info.tsv", sep="\t", col.names="entire_row")

# Set up a dataframe for these genes
genes_df <- data.frame(matrix(ncol=12, nrow=0))
taxa_list <- c("a_americanum", "d_variabilis", "h_longicornis", "i_hexagonus", 
               "i_inopinatus", "i_pacificus", "i_persulcatus", "i_ricinus",
               "i_scapularis", "o_turicata", "r_sanguineus")
colnames(genes_df) <- c("gene", taxa_list)

# Populate the dataframe with gene name and taxon representation
for (row in raw_busco_genes$entire_row) {
  # strsplit gives us a list and we want a simple character vector so we use unlist
  row_turned_list <- unlist(strsplit(row, split=" "))
  # Isolate gene name and put that in the dataframe as both an entry and a row name
  gene_name <- row_turned_list[1]
  append(x=row.names(genes_df), values=gene_name)
  genes_df[gene_name, "gene"] <- gene_name
  # Filling in taxon representation values
  for (taxon in taxa_list) {
    # If the taxon is represented in that gene we will have a value of 1, otherwise 0
    genes_df[gene_name, taxon] <- ifelse(test=(taxon %in% row_turned_list), yes=1, no=0)
  }
}

# Let's do some summary statistics
gene_names <- genes_df$gene
gene_taxon_counts <- rowSums(genes_df[, 2:12])
gene_taxon_counts_no_inopinatus <- rowSums(genes_df[, c(2:5, 7:12)])
ixodes_counts <- rowSums(genes_df[, 5:10])
ixodes_counts_no_inopinatus <- rowSums(genes_df[, c(5, 7:10)])
summary_genes <- data.frame(gene = gene_names, 
                            how_many_total = gene_taxon_counts, 
                            how_many_ixodes = ixodes_counts,
                            no_inopinatus = ixodes_counts_no_inopinatus)

# Taking a look at how many taxa represented in our genes
hist(gene_taxon_counts)
hist(gene_taxon_counts_no_inopinatus)
hist(ixodes_counts)
hist(ixodes_counts_no_inopinatus)

# We can pull out 203 genes where all taxa are represented
fully_represented_genes <- summary_genes[summary_genes$how_many_total == 11, "gene"]

# We can also pull out 238 genes where all Ixodes are represented
fully_represented_ixodes <- summary_genes[summary_genes$how_many_ixodes == 6, "gene"]

# We can finally pull out 956 genes where all Ixodes except I. inopinatus are represented
no_inopinatus_okay <- summary_genes[summary_genes$no_inopinatus == 5, "gene"]


# For importing these into the next script, 0b_subsetting_busco_genes.sh
to_export <- no_inopinatus_okay
# This gives the elements of the vector in the bash array format
  # () container, space in between each element, "" for each element
cat(paste("(\"", paste(to_export, collapse="\" \""), "\")", sep=""))

