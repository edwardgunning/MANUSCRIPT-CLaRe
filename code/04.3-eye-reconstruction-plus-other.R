# Load packages: ----------------------------------------------------------
library(GLaRe)
library(ggplot2)
library(magrittr)
source("load_Python_legacy_env.R")
set.seed(1)

# Load Data and Results: --------------------------------------------------
eye <- as.matrix(read.table(file = "data/Y_outlier_removed.txt"))
eye_glare_list <- readRDS(file = "data/eye-results-real.rds")
eye_pca <- eye_glare_list$glare$pca

# Plot 1: Anatomy of GLaRe Plot: ------------------------------------------
cairo_pdf(
  file = "figures/glare-anatomy-plot.pdf",
  width = 7,
  height = 7,
  family = "DejaVu Sans"
)
par(mfrow = c(1, 1), mar = c(5, 6, 4, 1), cex = 1.2)
GLaRe:::summary_correlation_plot(
  out_basisel = eye_pca,
  cvqlines = 0.9,
  attainment_rate = 0.95,
  tolerance_level = 0.05,
  r = eye_pca$r, q = eye_pca$q,
  qd = eye_pca$qd,
  breaks = eye_pca$breaks,
  method_name = "Demo of PCA on Glaucoma Data"
)
dev.off()


# Plot 2: Additional Functionality ----------------------------------------
set.seed(1)
cairo_pdf(
  file = "figures/additional-plots-01.pdf",
  width = 12, height = 6,
  family = "DejaVu Sans"
)
par(mfrow = c(1, 2), cex = 1.1)
GLaRe::distribution_plot(GLaRe_output = eye_pca)
title("(a) distribution_plot()")
GLaRe::plot_train_validation_ratio(GLaRe_output = eye_pca)
title("(b) plot_train_validation_ratio()")
dev.off()


# Plot 3: Observation-level Reconstruction: -------------------------------
GLaRe::plot_eye_reconstruction(GLaRe_output = eye_pca, y = eye[1, ]) +
  ggplot2::theme(legend.text = element_text(size = 8))

ggplot2::ggsave(
  filename = here::here("figures", "eye-reconstruction.pdf"),
  device = "pdf",
  width = 8.25,
  height = 6.74,
  dpi = 400
)




# Plot 4: Heatmap ---------------------------------------------------------
source(here::here("code", "ensure_plotly_export.R"))
ensure_plotly_export()

p <- eye_pca$heatmap %>%
  plotly::layout(
    font = list(size = 22),
    xaxis = list(
      tickfont = list(size = 22),
      tickangle = -45
    ),
    yaxis = list(
      tickfont = list(size = 22)
    ),
    margin = list(l = 120, b = 140, r = 140, t = 40)
  ) %>%
  plotly::style(
    colorbar = list(
      title = list(text = "Loss", side = "top"),
      tickfont = list(size = 18),
      tickvals = c(0.05, 0.2, 0.5, 1),
      ticktext = c("0.05", "0.2", "0.5", "1"),
      len = 0.8,
      thickness = 30,
      x = 1.08
    )
  )

p

plotly::save_image(
  p,
  file = here::here("figures", "eye-heatmap.png")
)


# Plot 5: Heatmap-of-K-for-alpha-epsilon ---------------------------------------
library(ggplot2)
heatmap_k <- generate_heatmap_of_K(
  sorted_loss_vec = eye_pca$Qrho_v,
  breaks = eye_pca$breaks,
  interactive = FALSE
)

heatmap_k
ggsave(here::here("figures", "eye-heatmap-K.pdf"),
  device = "pdf",
  width = 6,
  height = 4
)
