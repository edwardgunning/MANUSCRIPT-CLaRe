library(GLarE)
library(data.table)
library(ggplot2)
source("code/theme_gunning.R")
theme_gunning()

set.seed(1)
# Phoenome dataset:
PH_path <- "https://www.math.univ-toulouse.fr/~ferraty/SOFTWARES/NPFDA/npfda-phoneme.dat"
PH <- readr::read_table(file = PH_path, col_names = FALSE)
PH <- as.matrix(PH)[, 1:150]

PH_dt <- data.table(id = factor(1:2000), PH)
PH_dt_lng <- melt.data.table(data = PH_dt, id.vars = "id", variable.factor = FALSE, value.factor = FALSE)
PH_dt_lng[, variable := as.numeric(stringr::str_remove(variable, "X"))]

set.seed(1)
inds <- sample(1:2000, 5)
library(RColorBrewer)
myColors <- brewer.pal(5,"Set1")
ggplot(data = PH_dt_lng[id %in% inds]) +
  aes(x = variable, y = value, group = id, colour = id) +
  geom_line(alpha = 1) +
  scale_color_manual(values = myColors) +
  labs(x = expression("Frequency "~ (t)),
       y = expression("Log-periodogram "~ X[i](t)),
       title = "The phoneme Dataset") +
  theme(legend.position = "none")

ggsave(filename = "figures/phoneme.pdf", device = "pdf", width = 0.5 * 13 * 0.825, height = 0.5 *  8 * 0.685)



PH_glare_pca <- GLaRe(mat = PH, learn = "pca", latent_dim_by = 5)
PH_glare_dwt <- GLaRe(mat = PH, learn = "dwt", latent_dim_by = 5)
PH_glare_ae <- GLaRe(mat = PH, learn = "ae", latent_dim_by = 5, ae_args = list(link_fun = "linear", layer_1_dim = 200))

saveRDS(list(ae = PH_glare_ae,
             pca = PH_glare_pca,
             dwt = PH_glare_dwt), file = "data/phoneme-results.rds")

phoneme_results <- readRDS( file = "data/phoneme-results.rds")


cairo_pdf(file = "figures/phoneme-results.pdf", width = 12, height = 4, family="DejaVu Sans")
par(mfrow = c(1, 3), mar=c(5,6,4,1))
GLarE:::summary_correlation_plot(phoneme_results$pca,
                                 cvqlines = 0.9,
                                 attainment_rate = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(a) PCA",
                                 r = phoneme_results$pca$r,
                                 q = phoneme_results$pca$r,
                                 breaks = phoneme_results$pca$breaks,
                                 qd = phoneme_results$pca$qd)

GLarE:::summary_correlation_plot(phoneme_results$dwt,
                                 cvqlines = 0.9,
                                 attainment_rate = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(b) DWT",
                                 r = phoneme_results$dwt$r,
                                 q = phoneme_results$dwt$r,
                                 breaks = phoneme_results$dwt$breaks,
                                 qd = phoneme_results$dwt$qd)


GLarE:::summary_correlation_plot(phoneme_results$ae,
                                 cvqlines = 0.9,
                                 attainment_rate = 0.95,
                                 tolerance_level = 0.05,
                                 method_name = "(c) AE",
                                 r = phoneme_results$ae$r,
                                 q = phoneme_results$ae$r,
                                 breaks = phoneme_results$ae$breaks,
                                 qd = phoneme_results$ae$qd)
dev.off()


cairo_pdf(filename = "figures/phoneme-reconstruction.pdf", width = 0.45 * 13 * 0.825, height = 0.75 *  8 * 0.685, , family="DejaVu Sans")
plot_1D_reconstruction(GLaRe_output = phoneme_results$pca, Y = PH[inds, ])
dev.off()
