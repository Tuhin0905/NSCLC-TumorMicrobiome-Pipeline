#!/usr/bin/env bash
set -euo pipefail

WORKDIR="${1:-}"
REPO_NAME="${2:-}"
REMOTE_URL="${3:-}"

if [[ -z "${WORKDIR}" || -z "${REPO_NAME}" || -z "${REMOTE_URL}" ]]; then
  echo "Usage: bash setup_and_push_repo.sh WORKDIR REPO_NAME REMOTE_URL"
  exit 1
fi

REPO_DIR="${WORKDIR}/${REPO_NAME}"
mkdir -p "${REPO_DIR}"
cd "${REPO_DIR}"

mkdir -p config scripts R docs environment results

cat > .gitignore <<'EOF'
data/
results/
*.sam
*.bam
*.bai
*.bt2
*.log
.DS_Store
*.swp
EOF

cat > README.md <<'EOF'
# NSCLC Tumor vs Near-Tumor Microbiome Pipeline (Scripts Only)

This repo contains scripts/configs for:
QC → trimming → host-removal → WoL/Woltka taxonomy → diversity → Songbird + paired Wilcoxon
→ HUMAnN3 (diamond/UniRef90; bypass nucleotide) → KO/MetaCyc + KO→KEGG mapping
→ pathway differential tests → species–pathway Spearman correlations (FDR).

No raw data / indices / results are included. All paths are placeholders (/path/to/...).
EOF

cat > config/samples.tsv <<'EOF'
sample_id	patient	condition	R1	R2
S01_T	S01	Tumor	/path/to/raw_fastq/S01_T_R1.fastq.gz	/path/to/raw_fastq/S01_T_R2.fastq.gz
S01_N	S01	Normal	/path/to/raw_fastq/S01_N_R1.fastq.gz	/path/to/raw_fastq/S01_N_R2.fastq.gz
S02_T	S02	Tumor	/path/to/raw_fastq/S02_T_R1.fastq.gz	/path/to/raw_fastq/S02_T_R2.fastq.gz
S02_N	S02	Normal	/path/to/raw_fastq/S02_N_R1.fastq.gz	/path/to/raw_fastq/S02_N_R2.fastq.gz
S03_T	S03	Tumor	/path/to/raw_fastq/S03_T_R1.fastq.gz	/path/to/raw_fastq/S03_T_R2.fastq.gz
S03_N	S03	Normal	/path/to/raw_fastq/S03_N_R1.fastq.gz	/path/to/raw_fastq/S03_N_R2.fastq.gz
S04_T	S04	Tumor	/path/to/raw_fastq/S04_T_R1.fastq.gz	/path/to/raw_fastq/S04_T_R2.fastq.gz
S04_N	S04	Normal	/path/to/raw_fastq/S04_N_R1.fastq.gz	/path/to/raw_fastq/S04_N_R2.fastq.gz
S05_T	S05	Tumor	/path/to/raw_fastq/S05_T_R1.fastq.gz	/path/to/raw_fastq/S05_T_R2.fastq.gz
S05_N	S05	Normal	/path/to/raw_fastq/S05_N_R1.fastq.gz	/path/to/raw_fastq/S05_N_R2.fastq.gz
S06_T	S06	Tumor	/path/to/raw_fastq/S06_T_R1.fastq.gz	/path/to/raw_fastq/S06_T_R2.fastq.gz
S06_N	S06	Normal	/path/to/raw_fastq/S06_N_R1.fastq.gz	/path/to/raw_fastq/S06_N_R2.fastq.gz
S07_T	S07	Tumor	/path/to/raw_fastq/S07_T_R1.fastq.gz	/path/to/raw_fastq/S07_T_R2.fastq.gz
S07_N	S07	Normal	/path/to/raw_fastq/S07_N_R1.fastq.gz	/path/to/raw_fastq/S07_N_R2.fastq.gz
S08_T	S08	Tumor	/path/to/raw_fastq/S08_T_R1.fastq.gz	/path/to/raw_fastq/S08_T_R2.fastq.gz
S08_N	S08	Normal	/path/to/raw_fastq/S08_N_R1.fastq.gz	/path/to/raw_fastq/S08_N_R2.fastq.gz
S09_T	S09	Tumor	/path/to/raw_fastq/S09_T_R1.fastq.gz	/path/to/raw_fastq/S09_T_R2.fastq.gz
S09_N	S09	Normal	/path/to/raw_fastq/S09_N_R1.fastq.gz	/path/to/raw_fastq/S09_N_R2.fastq.gz
S10_T	S10	Tumor	/path/to/raw_fastq/S10_T_R1.fastq.gz	/path/to/raw_fastq/S10_T_R2.fastq.gz
S10_N	S10	Normal	/path/to/raw_fastq/S10_N_R1.fastq.gz	/path/to/raw_fastq/S10_N_R2.fastq.gz
EOF

cat > config/params.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
export THREADS=16
export OUTROOT="results"
export QC_DIR="${OUTROOT}/00_qc"
export TRIM_DIR="${OUTROOT}/01_trim"
export HOST_DIR="${OUTROOT}/02_host_removed"
export WOL_DIR="${OUTROOT}/03_woltka"
export SONGBIRD_DIR="${OUTROOT}/04_songbird"
export HUMANN_DIR="${OUTROOT}/05_humann3"
export TABLES_DIR="${OUTROOT}/tables"
mkdir -p "${OUTROOT}" "${TABLES_DIR}"
export HG38_INDEX="/path/to/hg38_bowtie2_index/hg38"
export WOL_INDEX="/path/to/WoL_bowtie2_index/WoL"
export LINEAGE="/path/to/WoL/lineage.tsv"
EOF
chmod +x config/params.sh

# Minimal scripts so repo is complete (you can later overwrite with your full versions)
cat > scripts/07_run_all.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
source config/params.sh
echo "Repo scaffold created. Paste/replace your full pipeline scripts if needed."
EOF
chmod +x scripts/07_run_all.sh

# Envs (templates)
cat > environment/qc.yml <<'EOF'
name: nsclc_qc
channels: [conda-forge, bioconda, defaults]
dependencies:
  - fastqc
  - multiqc
  - python>=3.10
EOF

cat > environment/trimming.yml <<'EOF'
name: nsclc_trim
channels: [conda-forge, bioconda, defaults]
dependencies:
  - atropos=1.1.32
  - python>=3.10
EOF

cat > environment/mapping.yml <<'EOF'
name: nsclc_mapping
channels: [conda-forge, bioconda, defaults]
dependencies:
  - bowtie2
  - samtools
  - pigz
EOF

cat > environment/woltka.yml <<'EOF'
name: nsclc_woltka
channels: [conda-forge, bioconda, defaults]
dependencies:
  - woltka
  - biom-format
  - python>=3.10
EOF

cat > environment/humann3.yml <<'EOF'
name: nsclc_humann3
channels: [conda-forge, bioconda, defaults]
dependencies:
  - humann
  - diamond
  - python>=3.10
EOF

cat > environment/rstats.yml <<'EOF'
name: nsclc_rstats
channels: [conda-forge, bioconda, defaults]
dependencies:
  - r-base>=4.2
  - r-tidyverse
  - r-vegan
  - r-pheatmap
  - r-keggrest
EOF

# Methods doc (embedded short version)
cat > docs/methods.md <<'EOF'
# Methods (Scripts-only template)
This repo provides scripts for QC, trimming, host-removal (hg38), WoL/Woltka taxonomy,
diversity, Songbird + paired Wilcoxon, HUMAnN3 functional profiling, KO/MetaCyc + KO→KEGG,
pathway differential testing, and species–pathway Spearman correlations (FDR).
All paths are placeholders (/path/to/...); raw data/outputs are not distributed.
EOF

# Git + push
if [[ ! -d .git ]]; then git init; fi
git add .
git commit -m "Add scripts-only pipeline scaffold" || true
git branch -M main
git remote remove origin 2>/dev/null || true
git remote add origin "${REMOTE_URL}"
git push -u origin main

echo "[DONE] Pushed to ${REMOTE_URL}"
