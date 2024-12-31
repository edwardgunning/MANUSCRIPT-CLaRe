# Packages and Set Up: ----------------------------------------------------
library(keras)
library(tensorflow)
tensorflow::set_random_seed(1)



# Set up data: ------------------------------------------------------------
mnist <- keras::dataset_mnist()

x_train <- mnist$train$x/255
x_train_flattened <- matrix(x_train, nrow(x_train), 784)

x_test <- mnist$test$x/255
x_test_flattened <- matrix(x_test, nrow(x_test), 784)




# Fit AE: -----------------------------------------------------------------


# Parameters: -------------------------------------------------------------

layer_1_dim <- 600
layer_2_dim <- 400
link_fun <- "sigmoid"
k <- 200
p <- 784

# Define the encoder
encoder <- keras::keras_model_sequential() %>%
  keras::layer_dense(units = layer_1_dim, activation = "relu", input_shape = p) %>%
  keras::layer_dense(units = layer_2_dim, activation = "relu") %>%
  keras::layer_dense(units = k, activation = "linear", name = "bottleneck")

# Define the decoder
decoder <- keras::keras_model_sequential() %>%
  keras::layer_dense(units = layer_2_dim, activation = "relu", input_shape = k) %>%
  keras::layer_dense(units = layer_1_dim, activation = "relu") %>%
  keras::layer_dense(units = p, activation = link_fun)

# Connect them to create the autoencoder
autoencoder <- keras::keras_model(inputs = encoder$input, outputs = decoder(encoder$output))
autoencoder %>% keras::compile(optimizer = "adam", loss = "binary_crossentropy")
autoencoder %>% keras::fit(x = x_train_flattened,
                           y = x_train_flattened,
                           epochs = 100,
                           batch_size = 16,
                           verbose = TRUE)


predictions_ae <- predict(object = autoencoder, x = x_train_flattened)
# PCA: --------------------------------------------------------------------

prcomp_object <- prcomp(x_train_flattened)
predictions_pca <- reconstruct_prcomp_train(prcomp_obj = prcomp_object, latent_dim = k)


ae_sqerr <- apply((predicions_ae - x_train_flattened)^2, 1, mean)
pca_sqerr <- apply((predictions_pca - x_train_flattened)^2, 1, mean)


boxplot(ae_sqerr, pca_sqerr)




# Go 2: -------------------------------------------------------------------

# Define the encoder
encoder_2 <- keras::keras_model_sequential() %>%
  keras::layer_dense(units = layer_2_dim, activation = "relu", input_shape = p) %>%
  keras::layer_dense(units = k, activation = "linear", name = "bottleneck")

# Define the decoder
decoder_2 <- keras::keras_model_sequential() %>%
  keras::layer_dense(units = layer_2_dim, activation = "relu", input_shape = k) %>%
  keras::layer_dense(units = p, activation = link_fun)


autoencoder_2 <- keras::keras_model(inputs = encoder_2$input, outputs = decoder_2(encoder_2$output))
autoencoder_2 %>% keras::compile(optimizer = "adam", loss = "binary_crossentropy")
autoencoder_2 %>% keras::fit(x = x_train_flattened,
                           y = x_train_flattened,
                           epochs = 100,
                           batch_size = 16,
                           verbose = TRUE)

predictions_ae_2 <- predict(object = autoencoder_2, x = x_train_flattened)
ae_2_sqerr <- apply((predictions_ae_2 - x_train_flattened)^2, 1, mean)



boxplot(ae_sqerr, pca_sqerr, ae_2_sqerr)



