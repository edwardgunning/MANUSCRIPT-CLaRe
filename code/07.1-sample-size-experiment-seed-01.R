library(GLarE)

tensorflow::set_random_seed(1)
eye <- as.matrix(read.table(file = "data/Y_outlier_removed.txt"))
eye_array <- tensorflow::array_reshape(eye, c(nrow(eye), 120, 120))

sample_sizes <- round(306 / (2^seq(0, 3, by = 1)))

inds_list <- pca_list <- dwt_list <- vector("list", length = length(sample_sizes))

par(mfrow = c(1, 4))

for (i in seq_along(sample_sizes)) {
  print(paste("Sample size =", sample_sizes[i]))
  inds_list[[i]] <- inds <- sample(1:306, replace = FALSE, size = sample_sizes[i])
  mat_i <- eye[inds, ]
  array_i <- eye_array[inds, , ]
  pca_list[[i]] <- GLaRe(mat = mat_i, kf = sample_sizes[i])
  dwt_list[[i]] <- GLaRe(mat = array_i, learn = "dwt.2d", latent_dim_to = 810, kf = sample_sizes[i])
}


saveRDS(object = list(dwt = dwt_list, pca = pca_list), file = "data/sample-size-results.rds")

results <- readRDS(file = "data/sample-size-results.rds")
dwt_list <- results$dwt
pca_list <- results$pca


summary_correlation_plot_custom <- function(out_basisel, cvqlines, attainment_rate, r, q, breaks, method_name, qd, tolerance_level, custom_xlim) {
  correlation_df <- GLarE:::transform_correlation_output(out_basisel, cvqlines, attainment_rate)
  plot(
    x = breaks,
    y = correlation_df[, "meansqcor_t"],
    type = "b",
    pch = 20,
    col = "green",
    lwd = 3,
    lty = 1,
    panel.first = c(abline(h = 0, lty = 1, col = "black"), abline(h = 1, lty = 1, col = "black")),
    xlab = "No. of Latent Features",
    ylab = expression(paste("Loss: 1 - Squared Correlation (", 1 - R^2, ")", sep = "")),
    xlim = custom_xlim,
    ylim = c(0, 1),
    main = paste("Latent Feature Representation \n Summary:", method_name)
  )
  lines(x = breaks[seq_len(r)], correlation_df[seq_len(r), "minsqcor_cv"], col = "royalblue", lwd = 2, type = "b", pch = 20)
  lines(x = breaks[seq_len(r)], correlation_df[seq_len(r), "meansqcor_cv"], col = "goldenrod", lwd = 2, type = "b", pch = 20)
  lines(x = breaks[seq_len(r)], correlation_df[seq_len(r), "maxsqcor_cv"], col = "red3", lwd = 2, type = "b", pch = 20)
  if (cvqlines == 0.5) {
    lines(x = breaks[seq_len(r)], correlation_df[seq_len(r), "medsqcor_cv"], col = "purple", lwd = 2, type = "b", pch = 20)
  } else if (cvqlines != 0.5) {
    lines(x = breaks[seq_len(r)], correlation_df[seq_len(r), "qchoice_cv"], col = "purple", lwd = 2, type = "b", pch = 20)
  }
  lines(x = breaks[seq_len(r)], correlation_df[seq_len(r), "attainment_rate_cv"], col = "grey", lwd = 2, lty = 2, type = "b", pch = 20)

  if (!is.na(qd)) {
    abline(v = qd, lty = 2, col = "grey")
    abline(h = tolerance_level, lty = 2, col = "grey")
    axis(side = 1, at = c(qd), labels = paste0("qd = ", qd), col = "darkgrey", font = 4, lwd = 3, padj = 1.2)
    axis(side = 2, at = c(tolerance_level), labels = paste0("ε = ", tolerance_level), col = "darkgrey", font = 4, lwd = 3, padj = 1.2)
  }

  legend("topright",
    legend = c(
      "CV Min Loss",
      "CV Mean Loss",
      paste("CV Percentile =", cvqlines, "Loss"),
      "CV Max Loss",
      "Training Mean Loss",
      paste("Attainment Rate = ", attainment_rate, "Loss")
    ),
    col = c("blue", "goldenrod", "purple", "red3", "green", "grey"),
    lty = c(1, 1, 1, 1, 1, 2),
    lwd = c(2, 2, 2, 2, 2, 2, 2),
    bg = "white"
  )
}

cairo_pdf(file = "figures/eye-sample-size-results-results-real.pdf", width = 15, height = 15 / 2, family = "DejaVu Sans")
par(mfrow = c(2, 4), mar = c(5, 6, 4, 1), cex = 0.72)
for (j in 1:4) {
  summary_correlation_plot_custom(pca_list[[j]],
    cvqlines = 0.9,
    attainment_rate = 0.95,
    tolerance_level = 0.05,
    method_name = paste0("PCA: N = ", sample_sizes[j]),
    r = pca_list[[j]]$r,
    q = pca_list[[j]]$q,
    breaks = pca_list[[j]]$breaks,
    qd = pca_list[[j]]$qd,
    custom_xlim = range(pca_list[[1]]$breaks)
  )
}

for (j in 1:4) {
  summary_correlation_plot_custom(dwt_list[[j]],
    cvqlines = 0.9,
    attainment_rate = 0.95,
    tolerance_level = 0.05,
    method_name = paste0("DWT: N = ", sample_sizes[j]),
    r = dwt_list[[j]]$r,
    q = dwt_list[[j]]$q,
    breaks = dwt_list[[j]]$breaks,
    qd = dwt_list[[j]]$qd,
    custom_xlim = range(dwt_list[[1]]$breaks)
  )
}

dev.off()
