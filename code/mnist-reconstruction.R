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
mnist_ae <- GLaRe(mat = x_train_flattened,
                  latent_dim_from = 101,
                  latent_dim_to = 101,
                  latent_dim_by = 1,
                  learn = "ae",
                  verbose = TRUE)

cairo_pdf(file = "figures/mnist-reconstruction.pdf",
          width = 8, height = 4,
          family="DejaVu Sans")
par(mfrow = c(1, 2))
plot_mnist_reconstruction(GLaRe_output = mnist_ae,
                          y = x_train_flattened[1,])
dev.off()

