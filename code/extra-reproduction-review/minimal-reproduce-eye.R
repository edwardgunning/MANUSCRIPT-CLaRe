# ------------------------------------------------------------------------#
# Script to minimally reproduce the Eye analysis conclusions --------------
# -- Only run AE (computationally expnsive) at qualifying dimension ------#
# ------------------------------------------------------------------------#
source("load_Python_legacy_env.R")
library(GLaRe)
eye <- as.matrix(read.table(file = "data/Y_outlier_removed.txt")) # data
eye_results <- readRDS(file = "data/eye-results-real.rds")
tensorflow::set_random_seed(1)
par(mfrow = c(1, 3))
# Reun PCA same settings:
pca_time <- system.time(
  eye_pca <- GLaRe(
    mat = eye,
    learn = "pca",
    latent_dim_by = 10
  )
)

# Reshape to 3-d array before applying 2-d DWT.
eye_array <- tensorflow::array_reshape(eye, c(nrow(eye), 120, 120))
# Then run DWT on same grid, should be quick.
dwt_time <- system.time(
  eye_dwt <- GLaRe(
    mat = eye_array,
    learn = "dwt.2d",
    latent_dim_by = 10,
    latent_dim_to = max(eye_pca$breaks)
  )
)

# Run AUTOENCODER
# But just run it at maximum K = 301, to show it doesn't obtain qd.
ae_time <- system.time(
  eye_ae <- GLaRe(
    mat = eye,
    learn = "ae",
    latent_dim_from = max(eye_results$glare$ae$breaks),
    latent_dim_to = max(eye_results$glare$ae$breaks),
    ae_args = list(link_fun = "linear")
  )
)
