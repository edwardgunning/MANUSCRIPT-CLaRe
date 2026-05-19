# NOTE: Helper functions only weork for PCA that does not scale columns for now.

reconstruct_prcomp_train <- function(prcomp_obj, latent_dim) {
  stopifnot(class(prcomp_obj) == "prcomp")
  scores <- prcomp_obj$x[, seq_len(latent_dim)]
  eig_vec <- prcomp_obj$rotation[, seq_len(latent_dim)]
  mean_centered_recon <- scores %*% t(eig_vec)
  sweep(mean_centered_recon, MARGIN =  2, STATS = prcomp_obj$center, FUN = "+", check.margin = TRUE)
}

reconstruct_prcomp_test <- function(prcomp_obj, newdata, latent_dim) {
  stopifnot(class(prcomp_obj) == "prcomp")
  
  pca_mean <- prcomp_obj$center
  eig_vec <- prcomp_obj$rotation[, seq_len(latent_dim)]
  
  # center test data around new mean
  newdata_mean_cent <-  sweep(newdata, 2, pca_mean, FUN = "-")
  
  # calculate new fpca scores on test data
  newdata_pca_scores <- newdata_mean_cent %*% (eig_vec)
  # multiply by eigenvectors
  newdata_hat_pca_mean_cent <- newdata_pca_scores %*% t(eig_vec)
  
  # add back training mean
  sweep(newdata_hat_pca_mean_cent, MARGIN = 2, STATS = pca_mean, FUN = "+")
}

transform_back_prcomp <- function(prcomp_obj, newdata_latent, latent_dim) {
  stopifnot(class(prcomp_obj) == "prcomp")
  stopifnot(ncol(newdata_latent) == latent_dim)
  pca_mean <- prcomp_obj$center
  eig_vec <- prcomp_obj$rotation[, seq_len(latent_dim)]
  
  # multiply by eigenvectors
  newdata_hat_pca_mean_cent <- newdata_latent %*% t(eig_vec)
  
  # add back training mean
  sweep(newdata_hat_pca_mean_cent, MARGIN = 2, STATS = pca_mean, FUN = "+")
}


transform_to_pca_space <- function(prcomp_obj, newdata, latent_dim) {
  stopifnot(class(prcomp_obj) == "prcomp")
  
  pca_mean <- prcomp_obj$center
  eig_vec <- prcomp_obj$rotation[, seq_len(latent_dim)]
  
  # center new data using training mean
  newdata_mean_cent <- sweep(newdata, 2, pca_mean, FUN = "-")
  
  # project into PCA space
  newdata_pca_scores <- newdata_mean_cent %*% eig_vec
  
  return(newdata_pca_scores)
}
