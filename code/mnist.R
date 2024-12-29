# Load packages: ----------------------------------------------------------
library(GLarE)

# Set up dataset: ---------------------------------------------------------
mnist <- keras::dataset_mnist()
## normalize so the range is (0,1)
x_train <- mnist$train$x/255
x_train_flattened <- matrix(x_train, nrow(x_train), 784)


# Random seed: ------------------------------------------------------------
tensorflow::set_random_seed(1)

# Run GLaRe ---------------------------------------------------------------
dwt_time <- system.time(expr = {mnist_dwt.2d <- GLaRe(mat = x_train,
                      latent_dim_from = 1,
                      latent_dim_to = 400,
                      latent_dim_by = 20,
                      learn = "dwt.2d",
                      verbose = TRUE)})["elapsed"]

pca_time <- system.time(expr = {mnist_pca <- GLaRe(mat = x_train_flattened,
                   latent_dim_from = 1,
                   latent_dim_to = 400,
                   latent_dim_by = 20,
                   learn = "pca",
                   verbose = TRUE)})["elapsed"]

ae_time <- system.time(expr = {mnist_ae <- GLaRe(mat = x_train_flattened,
                   latent_dim_from = 1,
                   latent_dim_to = 400,
                   latent_dim_by = 20,
                   learn = "ae",
                   verbose = TRUE)})["elapsed"]


# Save Results: -----------------------------------------------------------
saveRDS(object = list(glare = list(ae = mnist_ae, pca = mnist_pca, dwt = mnist_dwt.2d),
                      times = list(ae = ae_time, pca = pca_time, dwt = dwt_time)),
        file = "data/mnist-results.rds")


