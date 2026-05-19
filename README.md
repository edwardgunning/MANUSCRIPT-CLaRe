CLaRe: A General Evaluation Framework for Selecting Compact
near-lossless Latent Representations of High-Dimensional Object Data
================

This repository contains the analysis scripts and LaTeX files
accompanying the ***revised*** manuscript: “CLaRe: A General Evaluation
Framework for Selecting Compact near-lossless Latent Representations of
High-Dimensional Object Data”\* by Emma Zohner, Edward Gunning, Giles
Hooker and Jeffrey Morris.

The repository provides:

1.  Scripts for reproducing analyses presented in the manuscript.

<!-- 2. LaTeX files for generating the manuscript, including figures, tables, and supplementary materials. -->

2.  Integration with the [**GLaRe** R
    package](https://github.com/edwardgunning/GLaRe), which implements
    the CLaRe framework.

------------------------------------------------------------------------

## Installing the GLaRe Package

This manuscript relies heavily on the [**GLaRe** R
package](https://github.com/edwardgunning/GLaRe). You should run the
following commands to install the latest version from GitHub:

``` r
# install.packages("devtools")
devtools::install_github(repo = "https://github.com/edwardgunning/GLaRe")
library(GLaRe)
```

## Python Environment

The autoencoder representation uses a `keras` implementation. This
framework and code was developed using the original
[`keras`](https://cran.r-project.org/web/packages/keras/index.html) R
package, which is now deprecated. To ensure reproducibility for this
manuscript, we have created the following virtual Python environment
(`glare-legacy`):

``` r
library(reticulate)
use_python("~/.virtualenvs/glare-legacy/bin/python", required = TRUE)
py_config()
```

    ## python:         /Users/edwardgunning/.virtualenvs/glare-legacy/bin/python
    ## libpython:      /Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/3.9/lib/python3.9/config-3.9-darwin/libpython3.9.dylib
    ## pythonhome:     /Users/edwardgunning/.virtualenvs/glare-legacy:/Users/edwardgunning/.virtualenvs/glare-legacy
    ## version:        3.9.6 (default, Apr 30 2025, 02:07:17)  [Clang 17.0.0 (clang-1700.0.13.5)]
    ## numpy:          /Users/edwardgunning/.virtualenvs/glare-legacy/lib/python3.9/site-packages/numpy
    ## numpy_version:  1.24.3
    ## 
    ## NOTE: Python version was forced by use_python() function

To create a suitable virtual environment on your machine, you should
run:

------------------------------------------------------------------------

## Repository Overview

### Contents

- [`code/`](code/): R scripts for reproducing analyses and figures.
- [`main/`](main/): LaTeX files for individual parts of the manuscript,
  including main text, appendices, and references.
- [`data/`](data/): Datasets used in the analyses and generated results.
- [`figures/`](figures/): Generate figures for analysis.
- [`README.md`](README.md): This file, providing an overview of the
  repository.
- [`computation-time-results.md`](computation-time-results.md):
  Computation times for the analysis.

## Getting Started

### Prerequisites

- R (version \>= 4.0.0)
- RStudio (optional)
- LaTeX distribution (e.g., TeX Live, MikTeX, Overleaf for online
  compilation)
- The following R packages:
  - [**GLaRe** (available via
    GitHub)](https://github.com/edwardgunning/GLaRe)
  - Additional dependencies: `ggplot2`, `dplyr`, `tidyr`, `scales`,
    `gridExtra`.
- **IMPORTANT**: Python Environment

------------------------------------------------------------------------
