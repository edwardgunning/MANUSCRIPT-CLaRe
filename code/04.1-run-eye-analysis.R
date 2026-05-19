library(GLaRe)
source("load_Python_legacy_env.R")

# eye1 <- as.matrix(glaucoma_data) # simulated copy
eye2 <- as.matrix(read.table(file = "data/Y_outlier_removed.txt")) # data
# eye3 <- as.matrix(read.table(file = "data/Y_raw.txt")) # data

eye <- eye2 # we use this version.

tensorflow::set_random_seed(1)

par(mfrow = c(1, 3))
# Run AUTOENCODER
ae_time <- system.time(
  eye_ae <- GLaRe(
    mat = eye,
    learn = "ae",
    latent_dim_by = 10,
    ae_args = list(link_fun = "linear")
  )
)

# Run PCA:
pca_time <- system.time(
  eye_pca <- GLaRe(
    mat = eye,
    learn = "pca",
    latent_dim_by = 10
  )
)

# Reshape to 3-d array before applying 2-d DWT.
eye_array <- tensorflow::array_reshape(eye, c(nrow(eye), 120, 120))
dwt_time <- system.time(
  eye_dwt <- GLaRe(
    mat = eye_array,
    learn = "dwt.2d",
    latent_dim_by = 10,
    latent_dim_to = max(eye_pca$breaks)
  )
)

saveRDS(object = list(
  time = c(ae = ae_time, dwt = dwt_time, pca = pca_time),
  glare = list(ae = eye_ae, dwt = eye_dwt, pca = eye_pca)
), file = "data/eye-results-real.rds")
