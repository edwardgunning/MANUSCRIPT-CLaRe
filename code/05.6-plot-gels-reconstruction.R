gel_results <- readRDS("data/gels-results.rds")
library(GLarE)
tensorflow::set_random_seed(seed = 1)
load("data/proteomic_gels.RData")
gels.data <- aperm(gels.data, perm = c(3, 2, 1))
gels.data_vec <- keras::array_reshape(x = gels.data, dim = c(53, 861 * 646))

gel_results$glare$dwt[["learn"]] <- "dwt.2d"

cairo_pdf(
  file = "figures/gels-reconstruction.pdf",
  width = 8,
  height = 4,
  family = "DejaVu Sans"
)
par(mfrow = c(1, 2))
plot_gel_reconstruction(
  GLaRe_output = gel_results$glare$dwt,
  y = gels.data[1, , ]
)
dev.off()
