library(GLarE)
library(data.table)
library(ggplot2)
source("code/theme_gunning.R")
theme_gunning()

set.seed(1)
library(GLarE)

tensorflow::set_random_seed(seed = 1)

load("data/proteomic_gels.RData")
gels.data <-aperm(gels.data, perm = c(3, 2, 1))

gels.data_vec <- keras::array_reshape(x = gels.data, dim = c(53, 861 * 646))

par(mfrow = c(1, 2), cex = 0.75)
gels_pca <- GLaRe(mat = gels.data_vec, latent_dim_by = 1)

plot_dt <- data.table(training = gels_pca$corM_t, validation = gels_pca$corM_v, k = gels_pca$breaks)
max(gels_pca$breaks[!is.na(gels_pca$corM_v)], na.rm = T)
ggplot(plot_dt) +
  aes(x = k) +
  geom_point(aes(y = training, colour = "Training")) +
  geom_point(aes(y = validation, colour = "Validation")) +
  geom_line(aes(y = training, colour = "Training")) +
  geom_line(aes(y = validation, colour = "Validation")) +
  xlim(c(1, 41)) +
  theme(text = element_text(size = 14, family = "sans"),
        axis.title = element_text(size = 14),
        legend.title = element_blank(),
        plot.title = element_text(size = 15),
        legend.position = c(0.85, 0.5),
        legend.text = element_text(size = 15),
        legend.background = element_rect(colour = "black")) +
  labs(x = expression("Latent Feature Dimension" ~ (k)),
       y = expression("Information Loss: 1 - Sq. Cor" ~ (1 - rho^2)),
       title = "Training vs. Validation Losses")

ggsave(filename = "figures/training-validation.pdf", device = "pdf", width = 7, height = 6)
