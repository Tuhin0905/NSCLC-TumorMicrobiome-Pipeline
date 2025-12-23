# NSCLC Tumor vs Near-Tumor Microbiome Pipeline (Scripts Only)

This repo contains scripts/configs for:
QC → trimming → host-removal → WoL/Woltka taxonomy → diversity → Songbird + paired Wilcoxon
→ HUMAnN3 (diamond/UniRef90; bypass nucleotide) → KO/MetaCyc + KO→KEGG mapping
→ pathway differential tests → species–pathway Spearman correlations (FDR).

No raw data / indices / results are included. 
