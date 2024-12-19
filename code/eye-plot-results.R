
library(GLarE)
eye_results <- readRDS(file = "data/eye-results.rds")


cairo_pdf(file = "figures/eye-results.pdf", width = 12, height = 4, family="DejaVu Sans")
par(mfrow = c(1, 3), mar=c(5,6,4,1))
GLarE:::summary_correlation_plot(eye_results$glare$pca,
                                 cvqlines = 0.9,
                                 cutoff_criterion = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(a) PCA",
                                 r = eye_results$glare$pca$r,
                                 q = eye_results$glare$pca$r,
                                 breaks = eye_results$glare$pca$breaks,
                                 qc = eye_results$glare$pca$qc)

GLarE:::summary_correlation_plot(eye_results$glare$dwt,
                                 cvqlines = 0.9,
                                 cutoff_criterion = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(b) DWT",
                                 r = eye_results$glare$dwt$r,
                                 q = eye_results$glare$dwt$r,
                                 breaks = eye_results$glare$dwt$breaks,
                                 qc = eye_results$glare$dwt$qc)

GLarE:::summary_correlation_plot(eye_results$glare$ae,
                                 cvqlines = 0.9,
                                 cutoff_criterion = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(c) AE",
                                 r = eye_results$glare$ae$r,
                                 q = eye_results$glare$ae$r,
                                 breaks = eye_results$glare$ae$breaks,
                                 qc = eye_results$glare$ae$qc)
dev.off()
