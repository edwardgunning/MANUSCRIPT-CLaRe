# Setup: ------------------------------------------------------------------
library(GLarE) # load GLaRe package.

tensorflow::set_random_seed(seed = 1) # set random seed.

# load dataset.
load("data/proteomic_gels.RData")


# Reshape data: -----------------------------------------------------------
gels.data <- aperm(gels.data, perm = c(3, 2, 1))
gels.data_vec <- keras::array_reshape(x = gels.data, dim = c(53, 861 * 646))


# Apply GLaRe: ------------------------------------------------------------
ae_time <- system.time(gels_ae <- GLaRe(mat = gels.data_vec,
                                        latent_dim_by = 10,
                                        latent_dim_to = 51,
                                        method_name = "ae"))


# Save: -------------------------------------------------------------------
saveRDS(object = list(glare = list(ae = gels_ae),
                      times = list(ae = ae_time)),
        file = "data/gels-results-ae.rds")
