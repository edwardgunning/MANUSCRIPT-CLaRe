README
================

# MANUSCRIPT-GLaRe: A Graphical Tool for Assessing Losslessness of Latent Feature Representations

This repository contains the analysis scripts and LaTeX files
accompanying the manuscript: **“GLaRe: A Graphical Tool for Assessing
Losslessness of Latent Feature Representations”** by Edward Gunning.

The repository provides: 1. Scripts for reproducing analyses presented
in the manuscript. 2. LaTeX files for generating the CoLLaRe manuscript,
including figures, tables, and supplementary materials. 3. Integration
with the **GLaRe** R package, which implements the CoLLaRe framework.

------------------------------------------------------------------------

## Repository Overview

### Contents

- `code/`: R scripts for reproducing analyses and figures.
- `latex/`: LaTeX files for compiling the manuscript, including main
  text, appendices, and references.
- `data/`: Datasets used in the analyses or instructions for accessing
  them.
- `outputs/`: Generated results, including figures and tables.
- `README.md`: This file, providing an overview of the repository.

### Key Components

#### **Analysis Scripts**

- `glaucoma_analysis.R`: Analyzes the Glaucoma dataset, applying CoLLaRe
  to evaluate latent representations.
- `mnist_analysis.R`: Demonstrates CoLLaRe on the MNIST dataset with
  high-dimensional latent spaces.
- `proteomics_analysis.R`: Applies CoLLaRe to the Proteomic Gels
  dataset.
- `generate_figures.R`: Produces visualizations and heatmaps presented
  in the manuscript.

#### **LaTeX Files**

- `main.tex`: The primary LaTeX file for compiling the manuscript.
- `sections/`: Contains separate LaTeX files for manuscript sections
  (e.g., methods, results, discussion).
- `figures/`: Placeholder or generated images included in the
  manuscript.
- `bibliography.bib`: Bibliographic database for references cited in the
  manuscript.

------------------------------------------------------------------------

## Getting Started

### Prerequisites

- R (version \>= 4.0.0)
- RStudio (optional)
- LaTeX distribution (e.g., TeX Live, MikTeX, Overleaf for online
  compilation)
- The following R packages:
  - **GLaRe** (available via GitHub)
  - Additional dependencies: `ggplot2`, `dplyr`, `tidyr`, `scales`,
    `gridExtra`.

------------------------------------------------------------------------
