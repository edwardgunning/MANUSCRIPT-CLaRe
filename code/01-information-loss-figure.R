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
par(mfrow = c(1, 1))
matplot(t(PH)[, sample(1:nrow(PH), size = 20)], type = "l", xlab = "Freq.", ylab = "Log-periodogram")


ph_pca <- GLaRe(
  mat = PH,
  learn = "pca",
  latent_dim_from = 1,
  latent_dim_to = 20
)


rho_dt <- data.table(ph_pca$rho_v)
rho_dt$id <- seq_len(nrow(PH))
rho_dt_long <- melt.data.table(data = rho_dt, id.vars = "id", variable.factor = FALSE)
rho_dt_long[, variable := as.numeric(stringr::str_remove(variable, "V"))]

rho_mean <- rho_dt_long[, .(mean_value = mean(value)), by = variable]
id_max <- rho_dt_long[variable == 19][value == max(value), id]
id_min <- rho_dt_long[variable == 19][value == min(value), id]

set.seed(1)
sample_inds <- sample(1:nrow(PH), 100)

ggplot(data = rho_dt_long[id %in% sample_inds & variable %in% seq(1, 20, by = 2)]) +
  aes(x = variable, y = value, group = variable) +
  labs(
    x = expression("Latent Feature Dimension" ~ (k)),
    y = expression("Information Loss: 1 - Sq. Cor" ~ (1 - rho^2)),
    title = "Individual vs. Average Information Loss"
  ) +
  geom_dotplot(binaxis = "y", binwidth = 1 / 70, alpha = 0.4, colour = "lightblue", stackdir = "center") +
  scale_x_continuous(limits = c(1, 19.5), breaks = seq(1, 19, by = 2)) +
  scale_y_continuous(breaks = c(0, 0.5, 1), labels = c("0 = Lossless", "0.5", "1 = No Information")) +
  geom_point(data = rho_mean[variable %in% seq(1, 20, by = 2)], inherit.aes = FALSE, aes(x = variable, y = mean_value, colour = "Average Loss"), size = 3, pch = 15) +
  geom_line(data = rho_mean[variable %in% seq(1, 20, by = 2)], inherit.aes = FALSE, aes(x = variable, y = mean_value, colour = "Average Loss")) +
  theme(
    text = element_text(size = 14, family = "sans"),
    axis.title = element_text(size = 14),
    legend.title = element_blank(),
    axis.title.y = element_text(margin = margin(t = 0, r = -20, b = 0, l = 0, unit = "pt")),
    plot.title = element_text(size = 15),
    legend.position = c(0.85, 0.85),
    legend.text = element_text(size = 15),
    legend.background = element_rect(colour = "black")
  ) +
  scale_colour_manual(values = c("red3", "darkgreen", "cornflowerblue")) +
  geom_point(data = rho_dt_long[id == id_min & variable %in% seq(1, 20, by = 2)], inherit.aes = FALSE, aes(x = variable, y = value, colour = "Best Case")) +
  geom_point(data = rho_dt_long[id == id_max & variable %in% seq(1, 20, by = 2)], inherit.aes = FALSE, aes(x = variable, y = value, colour = "Worst Case")) +
  geom_line(data = rho_dt_long[id == id_min & variable %in% seq(1, 20, by = 2)], inherit.aes = FALSE, aes(x = variable, y = value, colour = "Best Case")) +
  geom_line(data = rho_dt_long[id == id_max & variable %in% seq(1, 20, by = 2)], inherit.aes = FALSE, aes(x = variable, y = value, colour = "Worst Case"))

ggsave(filename = "figures/info-loss.pdf", device = "pdf", width = 13 * 0.825, height = 8 * 0.685)
