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

`datasets download genome accession [assembly_ID] --include gff3,rna,cds,protein,genome,seq-report`


### Quality control ###
I used BUSCO to evaluate the completeness of each genome. 

`busco -i GCA_964199305.2_IXPA_v2_genomic.fna -l acari -m genome -o ~/phylo-class/data/i_pacificus_genome/i_pacificus_busco_acari`
