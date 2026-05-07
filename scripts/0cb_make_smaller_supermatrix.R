library(ape)

# Setting working directory
# setwd("//wsl.localhost/Ubuntu/home/ntlin/phylo-class/")

# Directory with genes to concatenate
genes_dir <- "./2b_aligned_all_ixodes_genes/"
# Directory for concatenation
concat_10_dir <- "./2ba_smaller_supermatrix/"

dir.create(concat_10_dir)

# Pull out the gene file names
gene_files <- paste(genes_dir, list.files(genes_dir, pattern='\\.fna$'), sep='')

# Makes a list of all taxa, sorted alphabetically
all_taxa <- character()
for (i in 1:length(gene_files)) {
  # Read just the names
  headers <- rownames(read.dna(gene_files[i], format="fasta"))
  all_taxa <- unique(c(all_taxa, headers))
}
all_taxa <- sort(all_taxa)

# Create output file and write header manually in PHYLIP sequential style
output_file <- "2b_supermatrix.phy"

for (taxon in all_taxa) {
  cat(paste0(">", taxon, "\n"), file = paste0(concat_10_dir,taxon, ".temp"), append = FALSE)
}
j<-1
for (i in seq_along(gene_files)) {

   j<-j+1
   if(j%%500 ==0 ){
   print(paste(j, "out of",length(gene_files),'genes',sep=' '))
   }
   # Read alignment
   aln <- read.dna(gene_files[i], format = "fasta", as.character = TRUE)
   gene_len <- ncol(aln)

   #ignore individuals with multiple sequences per gene
   aln <- aln[!duplicated(rownames(aln)), ]

   # Create a string of gaps for missing taxa
   gap_string <- paste(rep("-", gene_len), collapse = "")
   
   for(taxon in all_taxa) {
     # Check if this taxon exists in the current gene
     if(taxon %in% rownames(aln)) {
        # If yes, write its sequence
        seq_str <- paste(aln[taxon, ], collapse = "")
        cat(seq_str, file = paste0(concat_10_dir,taxon, ".temp"), append = TRUE)
      } else {
        # If no, write gaps
        cat(gap_string, file = paste0(concat_10_dir,taxon, ".temp"), append = TRUE)
      }
    }
    # Force garbage collection to free memory
    rm(aln)
    gc()
}


final_output <- "smaller_supermatrix.fna"
if(file.exists(final_output)) file.remove(final_output)

for(taxon in all_taxa) { #for all taxa
   # Read the sequence we built up
   lines <- readLines(paste0(concat_10_dir,taxon, ".temp"),warn = F)
   # Merge all sequence lines (lines 2 to end) into one line
   header <- lines[1]
   seq_body <- paste(lines[-1], collapse = "")

   cat(header, "\n", seq_body, "\n", file = paste(concat_10_dir,final_output,sep=''), append = TRUE)

   # Clean up temp file
   file.remove(paste0(concat_10_dir,taxon, ".temp"))
}
