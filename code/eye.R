library(GLarE)

eye <- as.matrix(glaucoma_data)

par(mfrow = c(1, 3))

ae_time <- system.time(
  eye_ae <- GLaRe(mat = eye, learn = "ae", latent_dim_by = 10)
)

pca_time <- system.time(
  eye_pca <- GLaRe(mat = eye, learn = "pca", latent_dim_by = 10)
)

eye_array <- tensorflow::array_reshape(eye, c(nrow(eye), 120, 120))
dwt_time <- system.time(
  eye_dwt <- GLaRe(mat = eye_array, learn = "dwt.2d", latent_dim_by = 10)
)

saveRDS(object = list(
  time = c(ae = ae_time, dwt = dwt_time, pca = pca_time),
  glare = list(ae = eye_ae, dwt = eye_dwt, pca = eye_pca)
), file = "data/eye-results.rds")




