library(GLarE)
mnist_results <- readRDS(file = "data/mnist-results.rds")
sapply(mnist_results$times, function(x) round(x / 60, 1))
mnist_results <- mnist_results$glare

cairo_pdf(file = "figures/mnist-results.pdf", width = 12, height = 4, family = "DejaVu Sans")
par(mfrow = c(1, 3), mar = c(5, 6, 4, 1))
GLarE:::summary_correlation_plot(mnist_results$pca,
  cvqlines = 0.9,
  attainment_rate = 0.95,
  tolerance_level = 0.05,
  method_name = "(a) PCA",
  r = mnist_results$pca$r,
  q = mnist_results$pca$r,
  breaks = mnist_results$pca$breaks,
  qd = mnist_results$pca$qd
)

GLarE:::summary_correlation_plot(mnist_results$dwt,
  cvqlines = 0.9,
  attainment_rate = 0.95,
  tolerance_level = 0.05,
  method_name = "(b) DWT",
  r = mnist_results$dwt$r,
  q = mnist_results$dwt$r,
  breaks = mnist_results$dwt$breaks,
  qd = mnist_results$dwt$qd
)

GLarE:::summary_correlation_plot(mnist_results$ae,
  cvqlines = 0.9,
  attainment_rate = 0.95,
  tolerance_level = 0.05,
  method_name = "(c) AE",
  r = mnist_results$ae$r,
  q = mnist_results$ae$r,
  breaks = mnist_results$ae$breaks,
  qd = mnist_results$ae$qd
)
dev.off()
