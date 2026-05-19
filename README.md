CLaRe: A General Evaluation Framework for Selecting Compact
near-lossless Latent Representations of High-Dimensional Object Data
================

This repository contains the analysis scripts and LaTeX files
accompanying the ***revised*** manuscript:
<center>

**“CLaRe: A General Evaluation Framework for Selecting Compact
near-lossless Latent Representations of High-Dimensional Object Data”**
</center>

by *Emma Zohner, Edward Gunning, Giles Hooker* and *Jeffrey Morris*.

The repository provides:

1.  Scripts for reproducing analyses presented in the manuscript.

2.  Integration with the [**GLaRe** R
    package](https://github.com/edwardgunning/GLaRe), which implements
    the CLaRe framework.

------------------------------------------------------------------------

## Installing the `GLaRe` Package

This manuscript relies heavily on the [**GLaRe** R
package](https://github.com/edwardgunning/GLaRe). You should run the
following commands to install the latest version from GitHub:

``` r
# install.packages("devtools")
devtools::install_github(repo = "https://github.com/edwardgunning/GLaRe")
library(GLaRe)
```

## Python Environment (Important)

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

``` bash
python3.9 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements-python.txt
```

[requirements-python.txt located here](requirements-python.txt).

Once the environment has been created, the Python environment can be
loaded from R using:

``` r
library(reticulate)
use_python(".venv/bin/python", required = TRUE)
py_config()
```

or convenience, the analysis scripts source the file
[`load_Python_legacy_env.R`](load_Python_legacy_env.R), which selects
the project-local `.venv` environment when available.

On the author’s machine, this falls back to the original local
environment:

``` r
library(reticulate)

project_python <- file.path(getwd(), ".venv", "bin", "python")

if (file.exists(project_python)) {
  reticulate::use_python(project_python, required = TRUE)
} else {
  reticulate::use_python("~/.virtualenvs/glare-legacy/bin/python", required = TRUE)
}

print(reticulate::py_config())
```

------------------------------------------------------------------------

## Repository Overview

### Contents

- [`code/`](code/): R scripts for reproducing analyses and figures. The
  running order is as follows:
  - **Information Loss Figure 1**
    [01-information-loss-figure.R](code/01-information-loss-figure.R)
    creates the example for Figure 1 of the manuscript.
  - **Distributional Summaries Figure 2**:
    [02-generror-distribution-summaries-figure.R](code/02-generror-distribution-summaries-figure.R)
    creates the Figure 2 in the paper, containing the three different
    plots of the generalization error distribution (GLaRe plot, dotplot,
    heatmap). The example here is PCA on the `phoneme` data.
  - **Datasets Figure 3**:
    [03-data-objects-plot.R](code/03-data-objects-plot.R) plots the
    datasets for the case studies (Figure 3 in the paper).
  - **Eye/ Glaucoma Case Study**:
    [04.1-run-eye-analysis.R](code/04.1-run-eye-analysis.R),[04.2-plot-eye-results.R](code/04.2-plot-eye-results.R),
    [04.3-eye-reconstruction-plus-other.R](code/04.3-eye-reconstruction-plus-other.R)
    deal with the running and plotting of the analysis of the eye data
    in the case study part 1.
  - **Gels Case Study**:
    [05.1-run-gels-pca-dwt.R](code/05.1-run-gels-pca-dwt.R),
    [05.2-run-gel-analysis-ae-batch.R](code/05.2-run-gel-analysis-ae-batch.R),
    [05.3-run-gel-analysis-ae-worker.R](code/05.3-run-gel-analysis-ae-worker.R),
    [05.4-combine-gels-ae-results.R](code/05.4-combine-gels-ae-results.R),
    [code/05.5-plot-gels-results.R](code/05.5-plot-gels-results.R),
    [05.6-plot-gels-reconstruction.R](code/05.6-plot-gels-reconstruction.R)
    deal with the running and plotting of the analysis of the gels data
    in the case study part 2. Note that because of memory limitations on
    the author’s laptop, we had to call GlaRe in a loop for each
    candidate qualifying dimension separately. The worker script being
    called is
    [05.3-run-gel-analysis-ae-worker.R](code/05.3-run-gel-analysis-ae-worker.R)
    and it is being called within a loop by
    [05.2-run-gel-analysis-ae-batch.R](code/05.2-run-gel-analysis-ae-batch.R).
  - **MNIST Case Study**:
    [06.1-run-mnist-analysis.R](code/06.1-run-mnist-analysis.R),
    [06.2-plot-mnist-results.R](code/06.2-plot-mnist-results.R),
    [06.3-mnist-reconstruction.R](code/06.3-mnist-reconstruction.R)
    contain the scripts for the mnist case study part 3.
  - **Sample Size Experiments Case Study**
    [07.1-sample-size-experiment-seed-01.R](code/07.1-sample-size-experiment-seed-01.R),
    [](code/07.2-sample-size-experiment-seed-02.R),
    [07.3-sample-size-experiment-seed-03.R](code/07.3-sample-size-experiment-seed-03.R).
  - **Additional (Appendix) Case Study `phoneme`**
    [08-phoneme-data.R](code/08-phoneme-data.R).
  - **Additional Analysis (Appendix) Multivariate Functional Data**:
    [additional-multivariate-functional-data.R](code/additional-multivariate-functional-data.R).
    Requires `fda` R package.
  - **Additional Data Example using Quantile Functions**:
    [additional-revision-quantiles.R)](code/additional-revision-quantiles.R)
    which uses the following helper functions in the file
    [additional-helpers-for-quantiles.R](code/additional-helpers-for-quantiles.R).
  - **Settings for `ggplot2` themes**:
    [theme_gunning.R](code/theme_gunning.R)
- [`data/`](data/): Datasets used in the analyses and generated results.
  - **DATASETS**:
    - The cleaned Glaucoma data is stored in
      [Y_outlier_removed.txt](data/Y_outlier_removed.txt).
    - The gels data is stored in
      [proteomic_gels.RData](data/proteomic_gels.RData)
    - We simply load the MNIST data using the `keras` package, running:
      `mnist <- keras::dataset_mnist()`.
    - We load the `phoneme` dataset directly from its website:

    ``` r
    PH_path <- "https://www.math.univ-toulouse.fr/~ferraty/SOFTWARES/NPFDA/npfda-phoneme.dat"
    PH <- readr::read_table(file = PH_path, col_names = FALSE)
    ```

    - Instructions for downloading the GaitRec dataset directly from its
      link are contained in
      [additional-multivariate-functional-data.R](code/additional-multivariate-functional-data.R).
  - **CACHED OUTPUTS**:
    - Due to their size, these are stored in GitHub LFS formats:
      - **Glaucoma Results** in
        [eye-results-real.rds](data/eye-results-real.rds)
      - **Gels Results** in
        [gels-ae-results-combined.rds](data/gels-ae-results-combined.rds)
        and
        [gels-results-run-split.rds](data/gels-results-run-split.rds).
      - **MNIST Results** in [mnist-results.rds](data/mnist-results.rds)
      - **`phoneme` Results (Appendix)** in
        [phoneme-results.rds](data/phoneme-results.rds)
- [`figures/`](figures/): Manuscript figures.
- [`README.md`](README.md): This file, providing an overview of the
  repository.
- [`computation-time-results.md`](computation-time-results.md):
  Computation times for the analysis.

## Additional Reproducibility Details

At the end of the analysis workflow, the computational environment can
be recorded using:

``` r
sessionInfo()
```

    ## R version 4.5.2 (2025-10-31)
    ## Platform: aarch64-apple-darwin20
    ## Running under: macOS Sequoia 15.7.3
    ## 
    ## Matrix products: default
    ## BLAS:   /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib 
    ## LAPACK: /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1
    ## 
    ## locale:
    ## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    ## 
    ## time zone: Europe/Dublin
    ## tzcode source: internal
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] reticulate_1.44.1
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] digest_0.6.39     fastmap_1.2.0     xfun_0.54         Matrix_1.7-4     
    ##  [5] lattice_0.22-7    knitr_1.50        htmltools_0.5.9   png_0.1-8        
    ##  [9] rmarkdown_2.30    cli_3.6.5         grid_4.5.2        compiler_4.5.2   
    ## [13] rstudioapi_0.17.1 tools_4.5.2       evaluate_1.0.5    Rcpp_1.1.0       
    ## [17] yaml_2.3.12       jsonlite_2.0.0    rlang_1.1.6

``` r
library(reticulate)
source("load_Python_legacy_env.R")
```

    ## python:         /Users/edwardgunning/.virtualenvs/glare-legacy/bin/python
    ## libpython:      /Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/3.9/lib/python3.9/config-3.9-darwin/libpython3.9.dylib
    ## pythonhome:     /Users/edwardgunning/.virtualenvs/glare-legacy:/Users/edwardgunning/.virtualenvs/glare-legacy
    ## version:        3.9.6 (default, Apr 30 2025, 02:07:17)  [Clang 17.0.0 (clang-1700.0.13.5)]
    ## numpy:          /Users/edwardgunning/.virtualenvs/glare-legacy/lib/python3.9/site-packages/numpy
    ## numpy_version:  1.24.3
    ## 
    ## NOTE: Python version was forced by use_python() function

``` r
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

``` r
py_run_string("
import sys
import numpy
import tensorflow as tf
import keras

print('Python executable:', sys.executable)
print('Python version:', sys.version)
print('NumPy:', numpy.__version__)
print('TensorFlow:', tf.__version__)
print('Keras:', keras.__version__)
")
```

    ## Python executable: /Users/edwardgunning/.virtualenvs/glare-legacy/bin/python
    ## Python version: 3.9.6 (default, Apr 30 2025, 02:07:17) 
    ## [Clang 17.0.0 (clang-1700.0.13.5)]
    ## NumPy: 1.24.3
    ## TensorFlow: 2.13.1
    ## Keras: 2.13.1

<!-- For the author's final run, this information was saved using: -->

<!-- ```bash -->

<!-- Rscript code/99-session-info.R > session-info.txt -->

<!-- ``` -->

<!-- The file `session-info.txt` records the R session, loaded package versions, Python executable, Python package versions, system information, and Git commit used for the final reproducibility check. -->
