library(GLarE)
tensorflow::set_random_seed(seed = 1)
load("data/proteomic_gels.RData")
gels.data <- aperm(gels.data, perm = c(3, 2, 1))
gels.data_vec <- keras::array_reshape(x = gels.data, dim = c(53, 861 * 646))
gels_ae <- GLaRe(mat = gels.data_vec, latent_dim_by = 10, learn = "ae")
saveRDS(object = gels_ae, file = "data/gels-ae-result.rds")

par(mfrow = c(1, 2), cex = 0.75)
gels_pca <- GLaRe(mat = gels.data_vec, latent_dim_by = 4)
gels_dwt.2d <- GLaRe(mat = gels.data, latent_dim_by = 100, latent_dim_to = 8000, learn = "dwt.2d")
gels_ae <- GLaRe(mat = gels.data_vec, latent_dim_by = 10, learn = "ae")

