Timing Results
================

## Glaucoma

``` r
eye_results <- readRDS(file = "data/eye-results-real.rds")
paste("Glaucoma, PCA:", round(eye_results$time["pca.elapsed"]/60, 1), "minutes")
```

    ## [1] "Glaucoma, PCA: 0.3 minutes"

``` r
paste("Glaucoma, DWT:", round(eye_results$time["dwt.elapsed"]/60, 1), "minutes")
```

    ## [1] "Glaucoma, DWT: 1.5 minutes"

``` r
paste("Glaucoma, AE:",round(eye_results$time["ae.elapsed"]/60, 1), "minutes")
```

    ## [1] "Glaucoma, AE: 145.3 minutes"

## Gels

``` r
gel_results <- readRDS("data/gels-results-run-split.rds")
paste("Gels, PCA:", round(gel_results$times[["pca"]]["elapsed"]/60, 1), "minutes")
```

    ## [1] "Gels, PCA: 0.6 minutes"

``` r
paste("Gels, DWT:",round(gel_results$times[["dwt"]]["elapsed"]/60, 1), "minutes")
```

    ## [1] "Gels, DWT: 46.4 minutes"

``` r
paste("Gels, AE:",round(readRDS("data/gels-ae-time-combined.rds"), 1), "minutes")
```

    ## [1] "Gels, AE: 545.4 minutes"

## MNIST

``` r
mnist_results <- readRDS(file = "data/mnist-results.rds")
paste("MNIST, PCA:", round(mnist_results$times[["pca"]]["elapsed"]/60, 1), "minutes")
```

    ## [1] "MNIST, PCA: 2.5 minutes"

``` r
paste("MNIST, DWT:", round(mnist_results$times[["dwt"]]["elapsed"]/60, 1), "minutes")
```

    ## [1] "MNIST, DWT: 23.5 minutes"

``` r
paste("MNIST, AE:",round(mnist_results$times[["ae"]]["elapsed"]/60, 1), "minutes")
```

    ## [1] "MNIST, AE: 1167.7 minutes"

## Session Info (Reproducibility)

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
    ## [1] stats     graphics  grDevices datasets  utils     methods   base     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Matrix_1.7-4       gtable_0.3.6       GLaRe_0.1.0        jsonlite_2.0.0    
    ##  [5] dplyr_1.2.1        compiler_4.5.2     renv_1.2.3         Rcpp_1.1.1-1.1    
    ##  [9] zeallot_0.2.0      tidyselect_1.2.1   waveslim_1.8.5     tensorflow_2.20.0 
    ## [13] tidyr_1.3.2        tfruns_1.5.4       png_0.1-9          scales_1.4.0      
    ## [17] yaml_2.3.12        fastmap_1.2.0      lattice_0.22-7     reticulate_1.46.0 
    ## [21] ggplot2_4.0.3      R6_2.6.1           generics_0.1.4     knitr_1.51        
    ## [25] htmlwidgets_1.6.4  tibble_3.3.1       pillar_1.11.1      RColorBrewer_1.1-3
    ## [29] rlang_1.2.0        multitaper_1.0-17  xfun_0.57          S7_0.2.2          
    ## [33] lazyeval_0.2.3     otel_0.2.0         viridisLite_0.4.3  plotly_4.12.0     
    ## [37] cli_3.6.6          magrittr_2.0.5     digest_0.6.39      grid_4.5.2        
    ## [41] rstudioapi_0.18.0  base64enc_0.1-6    lifecycle_1.0.5    vctrs_0.7.3       
    ## [45] evaluate_1.0.5     glue_1.8.1         data.table_1.18.4  whisker_0.4.1     
    ## [49] farver_2.1.2       codetools_0.2-20   keras_2.16.1       rmarkdown_2.31    
    ## [53] purrr_1.2.2        httr_1.4.8         tools_4.5.2        pkgconfig_2.0.3   
    ## [57] htmltools_0.5.9
