library(GLarE)
eye_results <- readRDS(file = "data/eye-results.rds")

round(eye_results$time["pca.elapsed"]/60, 1)
round(eye_results$time["dwt.elapsed"]/60, 1)
round(eye_results$time["ae.elapsed"]/60, 1)

cairo_pdf(file = "figures/eye-results.pdf", width = 12, height = 4, family="DejaVu Sans")
par(mfrow = c(1, 3), mar=c(5,6,4,1))
GLarE:::summary_correlation_plot(eye_results$glare$pca,
                                 cvqlines = 0.9,
                                 attainment_rate = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(a) PCA",
                                 r = eye_results$glare$pca$r,
                                 q = eye_results$glare$pca$r,
                                 breaks = eye_results$glare$pca$breaks,
                                 qd = eye_results$glare$pca$qd)

GLarE:::summary_correlation_plot(eye_results$glare$dwt,
                                 cvqlines = 0.9,
                                 attainment_rate = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(b) DWT",
                                 r = eye_results$glare$dwt$r,
                                 q = eye_results$glare$dwt$r,
                                 breaks = eye_results$glare$dwt$breaks,
                                 qd = eye_results$glare$dwt$qd)


GLarE:::summary_correlation_plot(eye_results$glare$ae,
                                 cvqlines = 0.9,
                                 attainment_rate = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(c) AE",
                                 r = eye_results$glare$ae$r,
                                 q = eye_results$glare$ae$r,
                                 breaks = eye_results$glare$ae$breaks,
                                 qd = eye_results$glare$ae$qd)
dev.off()
