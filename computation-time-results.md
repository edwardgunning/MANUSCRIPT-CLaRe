Timing Results
================

## Glaucoma

``` r
eye_results <- readRDS(file = "data/eye-results-real.rds")
paste("Glaucoma, PCA:", round(eye_results$time["pca.elapsed"]/60, 1), "minutes")
```

    ## [1] "Glaucoma, PCA: 1.6 minutes"

``` r
paste("Glaucoma, DWT:", round(eye_results$time["dwt.elapsed"]/60, 1), "minutes")
```

    ## [1] "Glaucoma, DWT: 1.7 minutes"

``` r
paste("Glaucoma, AE:",round(eye_results$time["ae.elapsed"]/60, 1), "minutes")
```

    ## [1] "Glaucoma, AE: 67.4 minutes"

## Gels

``` r
gel_results <- readRDS("data/gels-results.rds")



paste("Gels, PCA:", round(gel_results$times[["pca"]]["elapsed"]/60, 1), "minutes")
```

    ## [1] "Gels, PCA: 0.9 minutes"

``` r
paste("Gels, DWT:",round(gel_results$times[["dwt"]]["elapsed"]/60, 1), "minutes")
```

    ## [1] "Gels, DWT: 47.6 minutes"

``` r
paste("Gels, AE:",round(readRDS("data/gels-ae-time-combined.rds"), 1), "minutes")
```

    ## [1] "Gels, AE: 109.6 minutes"

## MNIST

``` r
mnist_results <- readRDS(file = "data/mnist-results.rds")
paste("MNIST, PCA:", round(mnist_results$times[["pca"]]["elapsed"]/60, 1), "minutes")
```

    ## [1] "MNIST, PCA: 16.2 minutes"

``` r
paste("MNIST, DWT:", round(mnist_results$times[["dwt"]]["elapsed"]/60, 1), "minutes")
```

    ## [1] "MNIST, DWT: 27.4 minutes"

``` r
paste("MNIST, AE:",round(mnist_results$times[["ae"]]["elapsed"]/60, 1), "minutes")
```

    ## [1] "MNIST, AE: 1115.3 minutes"

## Session Info (Reproducibility)

``` r
sessionInfo()
```

    ## R version 4.4.1 (2024-06-14)
    ## Platform: aarch64-apple-darwin20
    ## Running under: macOS Sonoma 14.5
    ## 
    ## Matrix products: default
    ## BLAS:   /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRblas.0.dylib 
    ## LAPACK: /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.0
    ## 
    ## locale:
    ## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    ## 
    ## time zone: America/New_York
    ## tzcode source: internal
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Matrix_1.7-0           gtable_0.3.5           jsonlite_1.8.8        
    ##  [4] dplyr_1.1.4            compiler_4.4.1         Rcpp_1.0.12           
    ##  [7] zeallot_0.1.0          tidyselect_1.2.1       waveslim_1.8.5        
    ## [10] tensorflow_2.16.0.9000 tidyr_1.3.1            tfruns_1.5.3          
    ## [13] png_0.1-8              scales_1.3.0           yaml_2.3.8            
    ## [16] fastmap_1.2.0          lattice_0.22-6         reticulate_1.38.0     
    ## [19] GLarE_0.1.0            ggplot2_3.5.1          R6_2.5.1              
    ## [22] generics_0.1.3         knitr_1.47             htmlwidgets_1.6.4     
    ## [25] tibble_3.2.1           munsell_0.5.1          pillar_1.9.0          
    ## [28] rlang_1.1.4            utf8_1.2.4             multitaper_1.0-17     
    ## [31] xfun_0.45              lazyeval_0.2.2         viridisLite_0.4.2     
    ## [34] plotly_4.10.4          cli_3.6.3              magrittr_2.0.3        
    ## [37] digest_0.6.36          grid_4.4.1             rstudioapi_0.16.0     
    ## [40] base64enc_0.1-3        lifecycle_1.0.4        vctrs_0.6.5           
    ## [43] evaluate_0.24.0        glue_1.7.0             data.table_1.15.4     
    ## [46] whisker_0.4.1          keras_2.15.0           fansi_1.0.6           
    ## [49] colorspace_2.1-0       rmarkdown_2.27         purrr_1.0.2           
    ## [52] httr_1.4.7             tools_4.4.1            pkgconfig_2.0.3       
    ## [55] htmltools_0.5.8.1
