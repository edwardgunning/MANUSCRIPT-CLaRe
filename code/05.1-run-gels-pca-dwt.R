library(GLarE)
tensorflow::set_random_seed(seed = 1)
load("data/proteomic_gels.RData")
gels.data <- aperm(gels.data, perm = c(3, 2, 1))
gels.data_vec <- keras::array_reshape(x = gels.data, dim = c(53, 861 * 646))
pca_time <- system.time(gels_pca <- GLaRe(mat = gels.data_vec, latent_dim_by = 10))
dwt_time <- system.time(gels_dwt.2d <- GLaRe(mat = gels.data, latent_dim_by = 100, latent_dim_to = 8000, learn = "dwt.2d"))
saveRDS(
  object = list(
    glare = list(pca = gels_pca, dwt = gels_dwt.2d),
    times = list(pca = pca_time, dwt = dwt_time)
  ),
  file = "data/gels-results.rds"
)
