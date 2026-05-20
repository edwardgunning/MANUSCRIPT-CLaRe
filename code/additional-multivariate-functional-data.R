source("load_Python_legacy_env.R")
# Packages: ---------------------------------------------------------------
library(readr) # CRAN v1.3.1
library(fda) # CRAN v5.1.9
library(tidyverse) # CRAN v1.3.0
library(modelsummary) # CRAN v1.4.1
library(data.table) # CRAN v1.14.2
# Data Import: ------------------------------------------------------------

# From:
# https://springernature.figshare.com/collections/GaitRec_A_large-scale_ground_reaction_force_dataset_of_healthy_and_impaired_gait/4788012/1

# Citation:
############
# Horsak, Brian; Slijepcevic, Djordje; Raberger, Anna-Maria; Schwab, Caterine; Worisch, Marianne; Zeppelzauer, Matthias (2020).
# GaitRec: A large-scale ground reaction force dataset of healthy and impaired gait. figshare. Collection.
# https://doi.org/10.6084/m9.figshare.c.4788012.v1
############

# Download the following Ground Reaction Forces Data:
# Force (F)
# vertical, anterior-posterior and medio-lateral force components (V, AP, ML)
# Legs: Both Left (left) and Right (right)
# Processing: Smoothed and Normalized (PRO)
# This is a big data set, it might take a while:

# Vertical Force:
GRF_F_V_PRO_left <- read_csv("https://ndownloader.figshare.com/files/22063191")
GRF_F_V_PRO_right <- read_csv("https://ndownloader.figshare.com/files/22063119")

# Medio-lateral Force:
GRF_F_ML_PRO_left <- read_csv("https://ndownloader.figshare.com/files/22063113")
GRF_F_ML_PRO_right <- read_csv("https://ndownloader.figshare.com/files/22063086")

# Anterior-Posterior Force:
GRF_F_AP_PRO_left <- read_csv("https://ndownloader.figshare.com/files/22063185")
GRF_F_AP_PRO_right <- read_csv("https://ndownloader.figshare.com/files/22063101")

# And associated MetaDeta, e.g., session and subject information:
GRF_metadata <- read_csv("https://ndownloader.figshare.com/files/22062960")

# .. you might have to wait.. it Will download!

# -------------------------------------------------------------------------
# AS PART OF REPRODUCIBILITY REVIEW:
# Combine with metadata:
gaitrec_archive <- list(
  data = list(
    GRF_F_V_PRO_left = GRF_F_V_PRO_left,
    GRF_F_V_PRO_right = GRF_F_V_PRO_right,
    GRF_F_ML_PRO_left = GRF_F_ML_PRO_left,
    GRF_F_AP_PRO_right = GRF_F_AP_PRO_right,
    GRF_metadata = GRF_metadata),
  metadata = list(
    dataset = "gaitrec",
    original_source_url = c(
      "https://ndownloader.figshare.com/files/22063191",
      "https://ndownloader.figshare.com/files/22063119",
      "https://ndownloader.figshare.com/files/22063113",
      "https://ndownloader.figshare.com/files/22063101",
      "https://ndownloader.figshare.com/files/22062960"
    ),
    saved_at = as.character(Sys.time()),
    script = "code/additional-multivariate-functional-data.R",
    note = "Local archived copy of the external gaitrec data used in the appendix analyses. Obtained directly from the gaitrec figshare."
  )
)
# Save to disk:
saveRDS(gaitrec_archive, "data/gaitrec_external_data.rds")
# checksums:
(md5_gaitrec <- tools::md5sum("data/gaitrec_external_data.rds"))
md5_gaitrec
writeLines(
  paste(names(md5_gaitrec), md5_gaitrec),
  "data/gaitrec_external_data_md5.txt"
)
# -------------------------------------------------------------------------
# -------------------------------------------------------------------------




# Data Wrangling: ---------------------------------------------------------
wide_df <- GRF_F_V_PRO_right %>%
  inner_join(
    y = GRF_F_V_PRO_left,
    by = c("SUBJECT_ID", "SESSION_ID", "TRIAL_ID")
  ) %>%
  inner_join(
    y = GRF_F_ML_PRO_right,
    by = c("SUBJECT_ID", "SESSION_ID", "TRIAL_ID")
  ) %>%
  inner_join(
    y = GRF_F_ML_PRO_left,
    by = c("SUBJECT_ID", "SESSION_ID", "TRIAL_ID")
  ) %>%
  inner_join(
    y = GRF_F_AP_PRO_right,
    by = c("SUBJECT_ID", "SESSION_ID", "TRIAL_ID")
  ) %>%
  inner_join(
    y = GRF_F_AP_PRO_left,
    by = c("SUBJECT_ID", "SESSION_ID", "TRIAL_ID")
  )

wide_dt <- as.data.table(wide_df)
names(wide_dt) <- str_replace(names(wide_dt), "F_V_PRO_(\\d{1,3})\\.x", "right_F_V_PRO_\\1")
names(wide_dt) <- str_replace(names(wide_dt), "F_V_PRO_(\\d{1,3})\\.y", "left_F_V_PRO_\\1")

names(wide_dt) <- str_replace(names(wide_dt), "F_ML_PRO_(\\d{1,3})\\.x", "right_F_ML_PRO_\\1")
names(wide_dt) <- str_replace(names(wide_dt), "F_ML_PRO_(\\d{1,3})\\.y", "left_F_ML_PRO_\\1")

names(wide_dt) <- str_replace(names(wide_dt), "F_AP_PRO_(\\d{1,3})\\.x", "right_F_AP_PRO_\\1")
names(wide_dt) <- str_replace(names(wide_dt), "F_AP_PRO_(\\d{1,3})\\.y", "left_F_AP_PRO_\\1")


chosen_sessions <- GRF_metadata %>%
  filter(SHOD_CONDITION == 1 & SPEED == 2 & TRAIN_BALANCED == 1) %>%
  pull(SESSION_ID)


GRF_metadata_dt <- data.table(GRF_metadata)
stopifnot(GRF_metadata_dt[SESSION_ID %in% chosen_sessions, uniqueN(SESSION_ID), by = SUBJECT_ID][, all(V1 == 1)])

class_label_dt <- GRF_metadata_dt[SESSION_ID %in% chosen_sessions, .(SUBJECT_ID, CLASS_LABEL)]


wide_dt$SESSION_ID %in% chosen_sessions

col_names <- names(wide_dt)[-c(1:3)]

wide_dt_chosen <- wide_dt[SESSION_ID %in% chosen_sessions]
wide_dt_chosen_av <- wide_dt_chosen[, as.list(apply(.SD, 2, mean)), by = SUBJECT_ID, .SDcols = col_names]

long_dt_chosen_av <- melt.data.table(wide_dt_chosen_av, id.vars = c("SUBJECT_ID"))


long_dt_chosen_av[
  , c("side", "direction", "time") :=
    as.data.table(
      str_match(
        variable,
        "^(left|right)_F_(V|AP|ML)_PRO_(\\d+)$"
      )[, -1] # drop full match column
    )
]

long_dt_chosen_av[, time := as.numeric(time)]
long_dt_chosen_av[, side := factor(side, levels = c("right", "left"), labels = c("Right", "Left"))]
long_dt_chosen_av[, direction := factor(direction,
  levels = c("V", "ML", "AP"),
  labels = c("Vertical", "Medio-lateral", "Anterior-posterior")
)]


plot_dt <- merge.data.table(x = long_dt_chosen_av, y = class_label_dt, by = "SUBJECT_ID", all = TRUE)
plot_dt_shuffled <- plot_dt[sample(1:nrow(plot_dt), size = nrow(plot_dt)), ]


plot_dt[, CLASS_LABEL := factor(CLASS_LABEL,
  levels = c(
    "HC",
    "A",
    "C",
    "H",
    "K"
  ), labels = c(
    "Healthy Control",
    "Ankle",
    "Calcaneus",
    "Hip",
    "Knee"
  )
)]
set.seed(1)
sample_of_subjects <- sample(unique(plot_dt$SUBJECT_ID), size = 100)
plot_sample <- plot_dt[SUBJECT_ID %in% sample_of_subjects]
# randomize subject plotting order
shuffled_ids <- sample(unique(plot_sample$SUBJECT_ID))
plot_sample[, SUBJECT_ID := factor(SUBJECT_ID, levels = shuffled_ids)]

ggplot(data = plot_sample) +
  aes(x = time, group = SUBJECT_ID, y = value, colour = CLASS_LABEL) +
  facet_grid(direction ~ side, scales = "free") +
  geom_line() +
  theme_bw() +
  labs(
    x = "Normalized Time (% of Stance)",
    y = "Force (Normalized to BW)",
    colour = "Group:"
  ) +
  theme(legend.position = "bottom")

ggsave(
  filename = here::here("figures", "gaitrec-data.pdf"),
  width = 6,
  height = 8
)


X_gaitrec <- as.matrix(wide_dt_chosen_av[, -c(1)])







mat_to_array <- function(X, n_fun = 6, n_time = 101) {
  stopifnot(is.matrix(X))
  stopifnot(ncol(X) == n_fun * n_time)

  n_subj <- nrow(X)

  A <- array(NA_real_, dim = c(n_time, n_subj, n_fun))

  for (j in seq_len(n_fun)) {
    cols_j <- ((j - 1) * n_time + 1):(j * n_time)
    A[, , j] <- t(X[, cols_j, drop = FALSE])
  }

  A
}

array_to_mat <- function(A) {
  stopifnot(length(dim(A)) == 3)

  n_time <- dim(A)[1]
  n_subj <- dim(A)[2]
  n_fun <- dim(A)[3]

  X <- matrix(NA_real_, nrow = n_subj, ncol = n_fun * n_time)

  for (j in seq_len(n_fun)) {
    cols_j <- ((j - 1) * n_time + 1):(j * n_time)
    X[, cols_j] <- t(A[, , j])
  }

  X
}


array_to_mfd <- function(X, argvals = seq(0, 100, length.out = nrow(X))) {
  Data2fd(argvals = argvals, y = X)
}


get_mfpca <- function(X, k) {
  n <- nrow(X)
  X_array <- mat_to_array(X = X, n_fun = 6, n_time = 101)
  X_mfd <- array_to_mfd(X = X_array, argvals = 0:100)
  mfpca_obj <- pca.fd(fdobj = X_mfd, nharm = k)
  mfpca_obj
}

center_fd_around_new_mean <- function(fdobj, mean.fd.obj)
{
  #  center functional data around a different mean
  #  useful for doing training and testing with functional data
  # i.e., for centering a test set of functional data around
  # the training set's mean.

  if (!(is.fd(fdobj) || is.fdPar(fdobj)))
    stop("First argument is neither an fd or an fdPar object.")
  if (is.fdPar(fdobj)) fdobvj = fdobj$fd

  if (!(is.fd(mean.fd.obj) || is.fdPar(mean.fd.obj)))
    stop("Second argument is neither an fd or an fdPar object.")
  if (is.fdPar(mean.fd.obj)) fdobvj = mean.fd.obj$fd

  coef     <- as.array(fdobj$coefs)
  coefd    <- dim(coef)
  ndim     <- length(coefd)
  basisobj <- fdobj$basis
  nbasis   <- basisobj$nbasis
  coefmean <- mean.fd.obj$coefs

  if(!(length(dim(coefmean)) == length(dim(coef)))) {
    stop("Dimensions of Mean Function and data don't match.")
  }
  if(length(dim(coefmean)) > 2 || length(dim(coef)) > 2) {
    if(! all((dim(coefmean)[c(1, 3)] == dim(coef)[c(1, 3)]))) {
      stop("Dimensions of Mean Function and data don't match.")
    }
  }

  if(!(dim(coefmean)[2] == 1)) {
    stop("Mean fd object contains replicate observations.")
  }

  if (ndim == 2) {
    coef     <- sweep(coef,1,coefmean[,1])
  } else {
    nvar <- coefd[3]
    for (j in 1:nvar) {
      coef[,,j] <- sweep(coef[,,j, drop = FALSE],1, coefmean[,1,j]) # drop = FALSE added to stop bug when only one observation.
    }
  }
  fdnames      <- fdobj$fdnames
  fdnames[[3]] <- paste("Centered", fdnames[[3]])
  centerfdobj  <- fd(coef, basisobj, fdnames)
  return(centerfdobj)
}

decenter_fd_around_new_mean <- function(fdobj, mean.fd.obj)
{
  #  center functional data around a different mean

  if (!(is.fd(fdobj) || is.fdPar(fdobj)))
    stop("First argument is neither an fd or an fdPar object.")
  if (is.fdPar(fdobj)) fdobvj = fdobj$fd

  if (!(is.fd(mean.fd.obj) || is.fdPar(mean.fd.obj)))
    stop("Second argument is neither an fd or an fdPar object.")
  if (is.fdPar(mean.fd.obj)) fdobvj = mean.fd.obj$fd

  coef     <- as.array(fdobj$coefs)
  coefd    <- dim(coef)
  ndim     <- length(coefd)
  basisobj <- fdobj$basis
  nbasis   <- basisobj$nbasis
  coefmean <- mean.fd.obj$coefs

  if(!(length(dim(coefmean)) == length(dim(coef)))) {
    stop("Dimensions of Mean Function and data don't match.")
  }
  if(length(dim(coefmean)) > 2 || length(dim(coef)) > 2) {
    if(! all((dim(coefmean)[c(1, 3)] == dim(coef)[c(1, 3)]))) {
      stop("Dimensions of Mean Function and data don't match.")
    }
  }

  if(!(dim(coefmean)[2] == 1)) {
    stop("Mean fd object contains replicate observations.")
  }

  if (ndim == 2) {
    coef     <- sweep(coef,1,coefmean[,1], FUN = "+")
  } else {
    nvar <- coefd[3]
    for (j in 1:nvar) {
      coef[,,j] <- sweep(coef[,,j, drop = FALSE],1, coefmean[,1,j], FUN = "+") # drop = FALSE added to stop bug when only one observation.
    }
  }
  fdnames      <- fdobj$fdnames
  fdnames[[3]] <- paste("De-centered", fdnames[[3]])
  centerfdobj  <- fd(coef, basisobj, fdnames)
  return(centerfdobj)
}

project_data_onto_fpcs <- function(fdobj, pca.fd_obj) {
  # adapted code from `fda` package for projecting
  # individual functions onto FPCs.
  # useful for when pca is calculated on training set but
  # we want fpc scores for the test set.


  stopifnot(class(pca.fd_obj) == "pca.fd")
  # NOTE: ASSUMES DATA REPRESENTED ON SAME BASIS AS FPCS
  # FOR MULTIVARIATE FUNCTIONAL DATA.
  stopifnot(fdobj$basis == pca.fd_obj$harmonics$basis)
  # this could be improved in time.


  harmfd <- pca.fd_obj$harmonics
  stopifnot(is.fd(harmfd))

  stopifnot(is.fd(fdobj))

  fd_coefs <- fdobj$coefs

  ndim  <- length(dim(fd_coefs))
  nrep <- dim(fd_coefs)[2]
  nharm <- dim(harmfd$coefs)[2]

  basisobj <- fdobj$basis
  nbasis   <- basisobj$nbasis
  type     <- basisobj$type

  if(ndim == 2) {
    nvar <- 1
  } else if(ndim == 3) {
    nvar <- dim(fd_coefs)[3]
  } else stop("Dimension of coefficient matrix wrong!")


  if (nvar == 1) {
    harmscr  <- inprod(fdobj, harmfd)
  } else {
    harmscr  <- array(0, c(nrep, nharm, nvar))
    coefarray <- fdobj$coefs
    harmcoefarray <- harmfd$coefs
    for (j in 1:nvar) {
      fdobjj  <- fd(as.matrix(coefarray[,,j]), basisobj)
      harmfdj <- fd(as.matrix(harmcoefarray[,,j]), basisobj)
      harmscr[,,j] <- inprod(fdobjj, harmfdj)
    }
  }
  harmscr
}

encode_mfd <- function(new_fd_obj, mfpca_obj) {
  # Checks for inputs: ------------------------------------------------------
  if (!(is.fd(new_fd_obj) || is.fdPar(new_fd_obj)))
    stop("First argument is neither an fd or an fdPar object.")
  if (is.fdPar(new_fd_obj)) fdobvj = new_fd_obj$fd

  if (!(class(mfpca_obj) == "pca.fd"))
    stop("Second argument is not a pca.fd object.")

  dimensionality_fd <- dim(new_fd_obj$coefs)
  dimensionality_pca <- dim(mfpca_obj$harmonics$coefs)
  if(!(length(dimensionality_pca) == length(dimensionality_fd))) {
    stop("Dimensions of first and second arguments don't match.")
  }

  if(length(dimensionality_fd) > 2) {
    if(!(all(dimensionality_pca[c(1, 3)] == dimensionality_fd[c(1, 3)]))) {
      stop("Dimensions of first and second arguments don't match.")
    }
  }

  if(!(new_fd_obj$basis == mfpca_obj$harmonics$basis)) {
    stop("For now, functional PCs and data must be represented on same basis.")
  }



  # Step 1 - Center the functions around the mean  --------------------------
  mean_fd_obj <- mfpca_obj$meanfd
  new_fd_obj_cent <- center_fd_around_new_mean(fdobj = new_fd_obj,
                                               mean.fd.obj = mean_fd_obj)


  # Step 2 - Project the centered data onto the fpcs ------------------------
  scores_new_fd_obj_cent <- project_data_onto_fpcs(fdobj = new_fd_obj_cent,
                                                   pca.fd_obj = mfpca_obj)
  scores_new_fd_obj_cent <- apply(scores_new_fd_obj_cent, c(1, 2), sum)
  scores_new_fd_obj_cent
}


encode_mat <- function(X_mat, mfpca_obj) {
  X_array <- mat_to_array(X = X_mat, n_fun = 6, n_time = 101)
  X_mfd <- array_to_mfd(X = X_array, argvals = 0:100)
  encode_mfd(X_mfd, mfpca_obj)
}


decode_mfd <- function(X_star, mfpca_obj) {

  if (!(class(mfpca_obj) == "pca.fd"))
    stop("Second argument is not a pca.fd object.")


  dimensionality_fd <- dim(mfpca_obj$harmonics$coefs)
  dimensionality_fd[2] <- nrow(X_star)
  mean_fd_obj <- mfpca_obj$meanfd

  # Reconstruct centered observations ---------------------------
  if (length(dimensionality_fd) == 2) {
    reconstructions_centered_coef <- t(X_star %*% t(mfpca_obj$harmonics$coefs))
  } else {
    nvar <- dimensionality_fd[3]
    nrep <- dimensionality_fd[2]
    nbasis <- dim(mfpca_obj$harmonics$coefs)[1]
    reconstructions_centered_coef <- array(data = NA, dim = c(nbasis, nrep, nvar))
    for (j in 1:nvar) {
      reconstructions_centered_coef[,,j] <- t(X_star %*% t(mfpca_obj$harmonics$coefs[,,j]))
    }
  }
  reconstructed_centered_fd <- fd(coef = reconstructions_centered_coef,
                                  basisobj = mfpca_obj$harmonics$basis)


  # Step 4 - 'de-center' the observations -----------------------------------
  reconstructed_fd <- decenter_fd_around_new_mean(fdobj = reconstructed_centered_fd,
                                                  mean.fd.obj = mean_fd_obj)

  stopifnot(ncol(reconstructed_fd$coefs) == nrow(X_star))


  # Step 6 - Return reconstructed functions and pc scores -------------------
  reconstructed_fd = reconstructed_fd
}

decode_mat <- function(X_star, mfpca_obj) {
  X_hat_mfd <- decode_mfd(X_star = X_star, mfpca_obj = mfpca_obj)
  X_hat_array <- eval.fd(evalarg = 0:100, fdobj = X_hat_mfd)
  X_hat_mat <- array_to_mat(A = X_hat_array)
  X_hat_mat
}


learn_mfpca <- function(Y, k) {
  mfpca_obj <- get_mfpca(X = Y, k = k)
  encode_fun <- function(Y) {
    encode_mat(X_mat = Y, mfpca_obj = mfpca_obj)
  }
  decode_fun <- function(Ystar) {
    decode_mat(X_star = Ystar, mfpca_obj = mfpca_obj)
  }

  list(Encode = encode_fun, Decode = decode_fun)
}



loss_function_mfd <- function(observed, predicted) {
  loss_vec_p <- vector(mode = "numeric", length = 6)
  for(j in 1:6) {
    jstart <- (j - 1) * 101
    start_inds <- jstart + 1
    end_inds <- jstart + 101
    loss_vec_p[j] <- GLaRe:::get_one_minus_squared_correlation(observed = observed[start_inds:end_inds],
                                                               predicted = predicted[start_inds:end_inds])
  }
  max(loss_vec_p)
}

loss_function_mfd_2 <- function(observed, predicted) {
  loss_vec_p <- vector(mode = "numeric", length = 6)
  for(j in 1:6) {
    jstart <- (j - 1) * 101
    start_inds <- jstart + 1
    end_inds <- jstart + 101
    loss_vec_p[j] <- GLaRe:::get_one_minus_squared_correlation(observed = observed[start_inds:end_inds],
                                                               predicted = predicted[start_inds:end_inds])
  }
  mean(loss_vec_p)
}

glare_gaitrec <- GLaRe::GLaRe(mat = X_gaitrec, latent_dim_to = 100,
                              learn = "user",
                              learn_function = learn_mfpca,
                              loss_function = loss_function_mfd)


pdf(file = "figures/GaitRec-GLaRe.pdf", width = 8 * 1.3, height = 4 * 1.3)
set.seed(1)
par(mfrow = c(1, 2), cex = 0.9)
glare_gaitrec_01 <- GLaRe::GLaRe(mat = X_gaitrec, latent_dim_to = 100,
                              learn = "user",
                              method_name = "MV-FPCA: max loss",
                              learn_function = learn_mfpca,
                              loss_function = loss_function_mfd)
glare_gaitrec_02 <- GLaRe::GLaRe(mat = X_gaitrec, latent_dim_to = 100,
                                 learn = "user",
                                 method_name = "MV-FPCA: mean loss",
                                 learn_function = learn_mfpca,
                                 loss_function = loss_function_mfd_2)
dev.off()

gl_list <- vector("list", length = 6)
par(mfrow = c(3, 2))
for(j in 1:6) {
  jstart <- (j - 1) * 101
  start_inds <- jstart + 1
  end_inds <- jstart + 101
  gl_list[[j]] <- GLaRe(mat = X_gaitrec[, start_inds:end_inds],
                        latent_dim_to = 50)
}




loss_mat <- matrix(NA, nrow = nrow(X_gaitrec), ncol = 6)

for(j in 1:6) {
  glare_obj <- gl_list[[j]]
  loss_mat[, j] <- glare_obj$rho_v[, 10]
}


max_loss_vec <- apply(loss_mat, 1, max)
quantile(max_loss_vec, 0.95)
