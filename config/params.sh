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
