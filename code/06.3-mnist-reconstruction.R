# Load packages: ----------------------------------------------------------
library(GLaRe)
source("load_Python_legacy_env.R")

# Set up dataset: ---------------------------------------------------------
mnist <- readRDS(file = here::here("data", "mnist_external_data.rds"))$data
## normalize so the range is (0,1)
x_train <- mnist$train$x / 255
x_train_flattened <- matrix(x_train, nrow(x_train), 784)

# mnist results
results <- readRDS(here::here("data", "mnist-results.rds"))

# Random seed: ------------------------------------------------------------
tensorflow::set_random_seed(1)

# Run GLaRe ---------------------------------------------------------------
qd <- results$glare$ae$qd
mnist_ae <- GLaRe(
  mat = x_train_flattened,
  latent_dim_from = results$glare$ae$qd,
  latent_dim_to = results$glare$ae$qd,
  latent_dim_by = 1,
  learn = "ae",
  verbose = TRUE
)

cairo_pdf(
  file = here::here("figures", "mnist-reconstruction.pdf"),
  width = 8,
  height = 4,
  family = "DejaVu Sans"
)
par(mfrow = c(1, 2))
plot_mnist_reconstruction(
  GLaRe_output = mnist_ae,
  y = x_train_flattened[1, ]
)
dev.off()
