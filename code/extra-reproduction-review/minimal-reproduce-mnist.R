# ------------------------------------------------------------------------#
# Script to minimally reproduce the MNIST analysis conclusions ------------
# -- Only run AE, DWT (computationally expnsive) at qualifying dimension -#
# ------------------------------------------------------------------------#

source(here::here("load_Python_legacy_env.R"))
library(GLaRe)
tensorflow::set_random_seed(seed = 1)
mem.maxVSize(vsize = 32 * 1000)


# Set up dataset: ---------------------------------------------------------
mnist <- readRDS(file = here::here("data", "mnist_external_data.rds"))$data
## normalize so the range is (0,1)
x_train <- mnist$train$x / 255
x_train_flattened <- matrix(x_train, nrow(x_train), 784)
mnist_results <- readRDS(file = here::here("data", "mnist-results.rds"))$glare


# Run GLaRe ---------------------------------------------------------------
# only run at qualifying dimensions fro AE.
# only run AS FAR as qd for each
par(mfrow = c(1, 3))

mnist_dwt.2d <- GLaRe(
  mat = x_train,
  latent_dim_from = mnist_results$pca$qd, # start only after pca qd.
  latent_dim_to = mnist_results$dwt$qd,
  latent_dim_by = 10,
  learn = "dwt.2d",
  verbose = TRUE
)

mnist_pca <- GLaRe(
  mat = x_train_flattened,
  latent_dim_from = 1,
  latent_dim_to = mnist_results$pca$qd,
  latent_dim_by = 10,
  learn = "pca",
  verbose = TRUE
)

mnist_ae <- GLaRe(
  mat = x_train_flattened,
  latent_dim_from = mnist_results$ae$qd,
  latent_dim_to = mnist_results$ae$qd,
  learn = "ae",
  verbose = TRUE
)
