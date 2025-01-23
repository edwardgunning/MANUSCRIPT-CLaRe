gel_results <- readRDS("data/gels-results.rds")
gel_results_ae <- readRDS(file = "data/gels-ae-results-combined.rds")

sapply(gel_results$times, function(x) round(x[["elapsed"]] / 60, 1))

gel_results <- gel_results$glare

cairo_pdf(file = "figures/gels-results.pdf", width = 12, height = 4, family = "DejaVu Sans")
par(mfrow = c(1, 3), mar = c(5, 6, 4, 1))
GLarE:::summary_correlation_plot(gel_results$pca,
  cvqlines = 0.9,
  attainment_rate = 0.95,
  tolerance_level = 0.05,
  method_name = "(a) PCA",
  r = gel_results$pca$r,
  q = gel_results$pca$r,
  breaks = gel_results$pca$breaks,
  qd = gel_results$pca$qc
)

GLarE:::summary_correlation_plot(gel_results$dwt,
  cvqlines = 0.9,
  attainment_rate = 0.95,
  tolerance_level = 0.05,
  method_name = "(b) DWT",
  r = gel_results$dwt$r,
  q = gel_results$dwt$r,
  breaks = gel_results$dwt$breaks,
  qd = gel_results$dwt$qc
)

GLarE:::summary_correlation_plot(gel_results_ae,
  cvqlines = 0.9,
  attainment_rate = 0.95,
  tolerance_level = 0.05,
  method_name = "(c) AE",
  r = gel_results_ae$r,
  q = gel_results_ae$r,
  breaks = gel_results_ae$breaks,
  qd = NA,
  show_legend = TRUE
)
dev.off()
