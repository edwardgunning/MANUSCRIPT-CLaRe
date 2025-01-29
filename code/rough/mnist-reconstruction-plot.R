library(GLarE)
library(keras)
mnist_results <- readRDS(file = "data/mnist-results.rds")[["glare"]]


# Set up dataset: ---------------------------------------------------------
mnist <- keras::dataset_mnist()
## normalize so the range is (0,1)
x_train <- mnist$train$x/255
x_train_flattened <- matrix(x_train, nrow(x_train), 784)


plot_mnist_reconstruction(GLaRe_output = mnist_results$ae,
                          y = x_train_flattened[1,])


