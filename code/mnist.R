library(GLarE)
mnist <- keras::dataset_mnist()
## normalize so the range is (0,1)
x_train <- mnist$train$x/255
# n <- nrow(x_train)
# x_train <- x_train[1:n,,]
x_train_flattened <- matrix(x_train, nrow(x_train), 784)

mnist_dwt.2d <- GLaRe(mat = x_train,
                      latent_dim_from = 1,
                      latent_dim_to = 400,
                      latent_dim_by = 20,
                      learn = "dwt.2d",
                      verbose = TRUE)

mnist_pca <- GLaRe(mat = x_train_flattened,
                   latent_dim_from = 1,
                   latent_dim_to = 400,
                   latent_dim_by = 20,
                   learn = "pca",
                   verbose = TRUE)

mnist_ae <- GLaRe(mat = x_train_flattened,
                   latent_dim_from = 1,
                   latent_dim_to = 400,
                   latent_dim_by = 20,
                   learn = "ae",
                   verbose = TRUE)


saveRDS(object = list(ae = mnist_ae, pca = mnist_pca, dwt = mnist_dwt.2d),
        file = "data/mnist-results.rds")


mnist_ae_test <- GLaRe(mat = x_train_flattened,
                       latent_dim_from = 200,
                       latent_dim_to = 220,
                       latent_dim_by = 20,
                       learn = "ae",
                       ae_args = list(loss = "binary_crossentropy", epochs = 50),
                       verbose = TRUE)
dim(x_train_flattened)
mnist_ae_test_2 <- GLaRe(mat = x_train_flattened,
                       latent_dim_from = 200,
                       latent_dim_to = 240,
                       latent_dim_by = 20,
                       learn = "ae",
                       ae_args = list(loss = "binary_crossentropy", layer_1_dim = 784, layer_2_dim = 600),
                       verbose = TRUE)
abline(h = 0.05)
learn_ae
