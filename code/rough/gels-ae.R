library(GLarE)
tensorflow::set_random_seed(seed = 1)
load("data/proteomic_gels.RData")
gels.data <- aperm(gels.data, perm = c(3, 2, 1))
gels.data_vec <- keras::array_reshape(x = gels.data, dim = c(53, 861 * 646))

k_seq <-seq(1, 53, by = 10)

results_list
flf_basissel(mat = gels.data_vec,
             latent_dim_from = k,
             latent_dim_by = 10,
             latent_dim_to = k,
             learn = "ae",
             ae_args = list(),
             kf = 5)

gels_ae <- GLaRe(mat = gels.data_vec, latent_dim_by = 10, latent_dim_to = 51, learn = "ae")
saveRDS(object = gels_ae, file = "data/gels-ae-result.rds")



