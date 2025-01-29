library(GLarE)
PH <- readr::read_table(file = "https://www.math.univ-toulouse.fr/~ferraty/SOFTWARES/NPFDA/npfda-phoneme.dat", col_names = FALSE)
PH <- as.matrix(PH)[, 1:150]
n <- nrow(PH)
sample_sizes_vec <- c(30, 100, 500, 1000, 2000)
n_sizes <- length(sample_sizes_vec)
pca_list <- dwt_list <- vector("list", length = n_sizes)

par(mfrow = c(1, 5), cex = 0.5)
for(i in seq_along(sample_sizes_vec)) {
  print(paste("Sample size =", sample_sizes_vec[i]))
  inds <- sample(1:n, size = sample_sizes_vec[i])
  data_i <- PH[inds, ]
  pca_list[[i]] <- GLaRe(
    mat = data_i,
    learn = "pca",
    kf = 5,
    sqcorrel = c("trainmean", "cvmean", "cvmin", "cvmax"),
    cvqlines = 0.5,
    cutoffcriterion = 0.95,
    cutoffvalue = 0.05,
    incr = 10,
    lim = ncol(PH),
    verbose = FALSE)

  # dwt_list[[i]] <- GLaRe(
  #   mat = data_i,
  #   learn = "dwt",
  #   kf = 5,
  #   sqcorrel = c("trainmean", "cvmean", "cvmin", "cvmax"),
  #   cvqlines = 0.5,
  #   cutoffcriterion = 0.95,
  #   cutoffvalue = 0.05,
  #   incr = 10,
  #   lim = 100,
  #   verbose = FALSE)
}

lapply(pca_list, plot_train_validation_ratio)
