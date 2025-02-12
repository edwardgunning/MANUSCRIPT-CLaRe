library(GLarE)
eye1 <- as.matrix(glaucoma_data) # simulated copy
eye2 <- as.matrix(read.table(file = "data/Y_outlier_removed.txt")) # data
eye3 <- as.matrix(read.table(file = "data/Y_raw.txt")) # data

eye <- eye2

tensorflow::set_random_seed(1)

par(mfrow = c(1, 3))

ae_time <- system.time(
  eye_ae <- GLaRe(
    mat = eye, learn = "ae", latent_dim_by = 10,
    ae_args = list(link_fun = "linear")
  )
)

pca_time <- system.time(
  eye_pca <- GLaRe(mat = eye, learn = "pca", latent_dim_by = 10)
)

eye_array <- tensorflow::array_reshape(eye, c(nrow(eye), 120, 120))
dwt_time <- system.time(
  eye_dwt <- GLaRe(
    mat = eye_array,
    learn = "dwt.2d",
    latent_dim_by = 10,
    latent_dim_to = 1000
  )
)



saveRDS(object = list(
  time = c(ae = ae_time, dwt = dwt_time, pca = pca_time),
  glare = list(ae = eye_ae, dwt = eye_dwt, pca = eye_pca)
), file = "data/eye-results-real.rds")


eye_dwt <- GLaRe(
  mat = eye_array,
  learn = "dwt.2d",
  latent_dim_by = 1,
  latent_dim_to = 301
)
