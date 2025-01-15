gel_results <- readRDS("data/gels-results.rds")

sapply(gel_results$times, function(x) round(x[["elapsed"]]/60,1))

gel_results <- gel_results$glare

cairo_pdf(file = "figures/gels-results.pdf", width = 12, height = 4, family="DejaVu Sans")
par(mfrow = c(1, 3), mar=c(5,6,4,1))
GLarE:::summary_correlation_plot(gel_results$pca,
                                 cvqlines = 0.9,
                                 cutoff_criterion = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(a) PCA",
                                 r = gel_results$pca$r,
                                 q = gel_results$pca$r,
                                 breaks = gel_results$pca$breaks,
                                 qc = gel_results$pca$qc)

GLarE:::summary_correlation_plot(gel_results$dwt,
                                 cvqlines = 0.9,
                                 cutoff_criterion = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(b) DWT",
                                 r = gel_results$dwt$r,
                                 q = gel_results$dwt$r,
                                 breaks = gel_results$dwt$breaks,
                                 qc = gel_results$dwt$qc)

plot(0, 0, type = "n")
dev.off()
