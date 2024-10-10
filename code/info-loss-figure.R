library(GLarE)
library(data.table)
library(ggplot2)
source("code/theme_gunning.R")
theme_gunning()

# Phoenome dataset:
PH_path <- "https://www.math.univ-toulouse.fr/~ferraty/SOFTWARES/NPFDA/npfda-phoneme.dat"
PH <- readr::read_table(file = PH_path, col_names = FALSE)
PH <- as.matrix(PH)[, 1:150]
par(mfrow = c(1, 1))
matplot(t(PH)[, sample(1:nrow(PH), size = 20)], type = "l", xlab = "Freq.", ylab = "Log-periodogram")


ph_pca <- GLaRe(
  mat = PH,
  learn = "pca",
  kf = 5,
  sqcorrel = c("trainmean", "cvmean", "cvmin", "cvmax"),
  cvqlines = 0.5,
  cutoffcriterion = 0.05,
  cutoffvalue = 0.9,
  incr = 1,
  lim = 20,
  verbose = FALSE)

rho_dt <- data.table(ph_pca$rho_v)
rho_dt$id <- seq_len(nrow(PH))
rho_dt_long <- melt.data.table(data = rho_dt, id.vars = "id", variable.factor = FALSE)
rho_dt_long[, variable := as.numeric(stringr::str_remove(variable, "V"))]

rho_mean <- rho_dt_long[, .(mean_value = mean(value)), by = variable]

set.seed(1)
ggplot(data = rho_dt_long[id %in% sample(1:nrow(PH), 100) & variable %in% seq(1, 20, by = 2)]) +
  aes(x = variable, y = value, group = variable) +
  labs(x = expression("Latent Feature Dimension" ~ (k)),
       y = expression("Information Loss = Sq. Cor" ~ (rho)),
       title = "Individual vs. Average Information Loss") +
  geom_dotplot(binaxis='y', binwidth = 1/70, alpha = 0.4, colour = "lightblue") +
  scale_x_continuous(limits = c(1, 19.5), breaks = seq(1, 19, by = 2)) +
  scale_y_continuous(breaks = c(0, 0.5, 1)) +
  geom_point(data = rho_mean[variable %in% seq(1, 20, by = 2)], inherit.aes = FALSE, aes(x = variable, y = mean_value, colour = "Average Loss"), size = 3, pch = 15) +
  geom_line(data = rho_mean[variable %in% seq(1, 20, by = 2)], inherit.aes = FALSE, aes(x = variable, y = mean_value, colour = "Average Loss")) +
  theme(text = element_text(size = 11, family = "sans"),
        axis.title = element_text(size = 11),
        legend.title = element_blank(),
        plot.title = element_text(size = 13),
        legend.position = c(0.75, 0.15),
        legend.text = element_text(size = 13),
        legend.background = element_rect(colour = "black")) +
  scale_colour_manual(values = c("red3"))

ggsave(filename = "figures/info-loss.pdf", device = "pdf", width = 13, height = 8)




