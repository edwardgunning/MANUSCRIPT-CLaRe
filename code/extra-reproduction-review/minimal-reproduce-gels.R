# ------------------------------------------------------------------------#
# Script to minimally reproduce the Gels analysis conclusions -------------
# -- Only run AE, DWT (computationally expnsive) at qualifying dimension -#
# ------------------------------------------------------------------------#

source(here::here("load_Python_legacy_env.R"))
library(GLaRe)
tensorflow::set_random_seed(seed = 1)

# Load data and organize:
load(here::here("data", "proteomic_gels.RData"))
gels.data <- aperm(gels.data, perm = c(3, 2, 1))
gels.data_vec <- keras::array_reshape(x = gels.data, dim = c(53, 861 * 646))
# Read in results (so QD can be used)
gel_results <- readRDS(here::here("data", "gels-results-run-split.rds"))
gel_results_ae <- readRDS(file = here::here("data", "gels-ae-results-combined.rds"))


par(mfrow = c(1, 3))
# PCA (run in full, should be no issues)
gels_pca <- GLaRe(mat = gels.data_vec, latent_dim_by = 10)
# Only run DWT at full (very large) qd
# Show that it achieves at qd
gels_dwt.2d <- GLaRe(mat = gels.data,
                     latent_dim_from = gel_results$glare$dwt$qd,
                     latent_dim_to = gel_results$glare$dwt$qd,
                     learn = "dwt.2d")
gels_ae <- GLaRe(mat = gels.data_vec,
                 latent_dim_from = max(gel_results_ae$breaks),
                 latent_dim_to = max(gel_results_ae$breaks),
                 learn = "ae",
                 ae_args = list(link_fun = "linear"))
