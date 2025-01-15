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
PH_glare_ae <- GLaRe(mat = PH, learn = "ae", latent_dim_by = 5, ae_args = list(link_fun = "linear"))

plot_1D_reconstruction(GLaRe_output = PH_glare_pca, Y = PH[inds, ])
