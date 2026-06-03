# This script provides a verification of cached results
# without having to run individual analyses. Can be used to check that the
# paper matches the outputs at a high-level.
library(GLaRe)

# Eye ---------------------------------------------------------------------

## Read in cached results -------------------------------------------------
eye_results <- readRDS(file = here::here("data", "eye-results-real.rds"))

print("-------------- EYE --------------")

## Print Qualifying Dimensions -------------------------------------------
qd_print <- function(qd) {
  if (is.na(qd)) {
    paste("qd not found")
  } else {
    paste("qd = ", qd)
  }
}
paste("Eye PCA", qd_print(qd = eye_results$glare$pca$qd))
paste("Eye DWT", qd_print(qd = eye_results$glare$dwt$qd))
paste("Eye AE", qd_print(qd = eye_results$glare$ae$qd))

## Display GLaRe Plots: ----------------------------------------------------
par(
  mfrow = c(1, 3),
  mar = c(5, 6, 4, 1),
  cex = 0.9
)
GLaRe:::summary_correlation_plot(eye_results$glare$pca,
  cvqlines = 0.9,
  attainment_rate = 0.95,
  tolerance_level = 0.05,
  method_name = "(a) PCA",
  r = eye_results$glare$pca$r,
  q = eye_results$glare$pca$r,
  breaks = eye_results$glare$pca$breaks,
  qd = eye_results$glare$pca$qd,
  cex_legend = 0.65
)

GLaRe:::summary_correlation_plot(eye_results$glare$dwt,
  cvqlines = 0.9,
  attainment_rate = 0.95,
  tolerance_level = 0.05,
  method_name = "(b) DWT",
  r = eye_results$glare$dwt$r,
  q = eye_results$glare$dwt$r,
  breaks = eye_results$glare$dwt$breaks,
  qd = eye_results$glare$dwt$qd,
  cex_legend = 0.65,
  show_legend = FALSE
)

GLaRe:::summary_correlation_plot(eye_results$glare$ae,
  cvqlines = 0.9,
  attainment_rate = 0.95,
  tolerance_level = 0.05,
  method_name = "(c) AE",
  r = eye_results$glare$ae$r,
  q = eye_results$glare$ae$r,
  breaks = eye_results$glare$ae$breaks,
  qd = eye_results$glare$ae$qd,
  cex_legend = 0.65,
  show_legend = FALSE
)


## Print Timing Results --------------------------------------------------


paste("Eye PCA Time:", round(eye_results$time["pca.elapsed"] / 60, 1),
      "minutes")
paste("Eye DWT Time:", round(eye_results$time["dwt.elapsed"] / 60, 1),
      "minutes")
paste("Eye AE Time:", round(eye_results$time["ae.elapsed"] / 60, 1),
      "minutes")



# Gels --------------------------------------------------------------------
print("-------------- GELS --------------")
## Read in cached results -------------------------------------------------
gel_results <- readRDS("data/gels-results-run-split.rds")
gel_results_ae <- readRDS(file = "data/gels-ae-results-combined.rds")
gel_times_ae <- readRDS(file = "data/gels-ae-time-combined.rds")
# note ae been converted to minutes in combination

## Print Qualifying Dimensions -------------------------------------------

paste("Gels PCA", qd_print(qd = gel_results$glare$pca$qd))
paste("Gels DWT", qd_print(qd = gel_results$glare$dwt$qd))
paste("Gels AE", qd_print(qd = gel_results_ae$qd))

## Display GLaRe Plots: ----------------------------------------------------
par(mfrow = c(1, 3), mar = c(5, 6, 4, 1), cex = 0.9)
GLaRe:::summary_correlation_plot(gel_results$glare$pca,
                                 cvqlines = 0.9,
                                 attainment_rate = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(a) PCA",
                                 r = gel_results$glare$pca$r,
                                 q = gel_results$glare$pca$r,
                                 breaks = gel_results$glare$pca$breaks,
                                 qd = gel_results$glare$pca$qd
)

GLaRe:::summary_correlation_plot(gel_results$glare$dwt,
                                 cvqlines = 0.9,
                                 attainment_rate = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(b) DWT",
                                 r = gel_results$glare$dwt$r,
                                 q = gel_results$glare$dwt$r,
                                 breaks = gel_results$glare$dwt$breaks,
                                 qd = gel_results$glare$dwt$qd,
                                 show_legend = FALSE
)

GLaRe:::summary_correlation_plot(gel_results_ae,
                                 cvqlines = 0.9,
                                 attainment_rate = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(c) AE",
                                 r = gel_results_ae$r,
                                 q = gel_results_ae$r,
                                 breaks = gel_results_ae$breaks,
                                 qd = NA,
                                 show_legend = FALSE
)

## Print Timing Results --------------------------------------------------
paste("Gels PCA Time:", round(gel_results$times$pca["elapsed"] / 60, 1),
      "minutes")
paste("Gels DWT Time:", round(gel_results$times$dwt["elapsed"] / 60, 1),
      "minutes")
# Note this has already been divided by 60 in script 05.4 (converted to minutes)
paste("Gels AE Time:", round(gel_times_ae, 1),
      "minutes")



# MNIST ---------------------------------------------------------------------
print("-------------- MNIST --------------")
## Read in cached results -------------------------------------------------
mnist_results <- readRDS(file = here::here("data", "mnist-results.rds"))

## Print Qualifying Dimensions -------------------------------------------

paste("mnist PCA", qd_print(qd = mnist_results$glare$pca$qd))
paste("mnist DWT", qd_print(qd = mnist_results$glare$dwt$qd))
paste("mnist AE", qd_print(qd = mnist_results$glare$ae$qd))

## Display GLaRe Plots: ----------------------------------------------------
par(
  mfrow = c(1, 3),
  mar = c(5, 6, 4, 1),
  cex = 0.9
)
GLaRe:::summary_correlation_plot(mnist_results$glare$pca,
                                 cvqlines = 0.9,
                                 attainment_rate = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(a) PCA",
                                 r = mnist_results$glare$pca$r,
                                 q = mnist_results$glare$pca$r,
                                 breaks = mnist_results$glare$pca$breaks,
                                 qd = mnist_results$glare$pca$qd,
                                 cex_legend = 0.65
)

GLaRe:::summary_correlation_plot(mnist_results$glare$dwt,
                                 cvqlines = 0.9,
                                 attainment_rate = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(b) DWT",
                                 r = mnist_results$glare$dwt$r,
                                 q = mnist_results$glare$dwt$r,
                                 breaks = mnist_results$glare$dwt$breaks,
                                 qd = mnist_results$glare$dwt$qd,
                                 cex_legend = 0.65,
                                 show_legend = FALSE
)

GLaRe:::summary_correlation_plot(mnist_results$glare$ae,
                                 cvqlines = 0.9,
                                 attainment_rate = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(c) AE",
                                 r = mnist_results$glare$ae$r,
                                 q = mnist_results$glare$ae$r,
                                 breaks = mnist_results$glare$ae$breaks,
                                 qd = mnist_results$glare$ae$qd,
                                 cex_legend = 0.65,
                                 show_legend = FALSE
)


## Print Timing Results --------------------------------------------------
paste("mnist PCA Time:", round(mnist_results$time$pca["elapsed"] / 60, 1),
      "minutes")
paste("mnist DWT Time:", round(mnist_results$time$dwt["elapsed"] / 60, 1),
      "minutes")
paste("mnist AE Time:", round(mnist_results$time$ae["elapsed"] / 60, 1),
      "minutes")
