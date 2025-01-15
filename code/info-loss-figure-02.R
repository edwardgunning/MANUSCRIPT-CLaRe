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
  kf = 5,
  latent_dim_to = 20,
  verbose = FALSE)



# Plot 1: -----------------------------------------------------------------
rho_dt <- data.table(ph_pca$rho_v)
rho_dt$id <- seq_len(nrow(PH))
rho_dt_long <- melt.data.table(data = rho_dt, id.vars = "id", variable.factor = FALSE)
rho_dt_long[, variable := as.numeric(stringr::str_remove(variable, "V"))]

rho_mean <- rho_dt_long[, .(mean_value = mean(value)), by = variable]
id_max <- rho_dt_long[variable==19][value == max(value), id]
id_min <- rho_dt_long[variable==19][value == min(value), id]

set.seed(1)
sample_inds <- sample(1:nrow(PH), 100)

p1 <- ggplot(data = rho_dt_long[id %in% sample_inds & variable %in% seq(1, 20, by = 2)]) +
  aes(x = variable, y = value, group = variable) +
  labs(x = expression("Latent Feature Dimension" ~ (k)),
       y = expression("Information Loss: 1 - Sq. Cor" ~ (1 - rho^2)),
       title = "Individual vs. Average Information Loss") +
  geom_dotplot(binaxis='y', binwidth = 1/70, alpha = 0.4, colour = "lightblue", stackdir = "center") +
  scale_x_continuous(limits = c(1, 19.5), breaks = seq(1, 19, by = 2)) +
  scale_y_continuous(breaks = c(0, 0.5, 1), labels = c("0 = Lossless", "0.5", "1 = No Information")) +
  geom_point(data = rho_mean[variable %in% seq(1, 20, by = 2)], inherit.aes = FALSE, aes(x = variable, y = mean_value, colour = "Average Loss"), size = 3, pch = 15) +
  geom_line(data = rho_mean[variable %in% seq(1, 20, by = 2)], inherit.aes = FALSE, aes(x = variable, y = mean_value, colour = "Average Loss")) +
  theme(text = element_text(size = 14, family = "sans"),
        axis.title = element_text(size = 14),
        legend.title = element_blank(),
        axis.title.y = element_text(margin = margin(t = 0, r = - 20, b = 0, l = 0, unit = "pt")),
        plot.title = element_text(size = 15),
        legend.position = c(0.85, 0.85),
        legend.text = element_text(size = 15),
        legend.background = element_rect(colour = "black")) +
  scale_colour_manual(values = c("red3", "darkgreen", "cornflowerblue")) +
  geom_point(data = rho_dt_long[id == id_min & variable %in% seq(1, 20, by = 2)], inherit.aes = FALSE, aes(x = variable, y = value, colour = "Best Case")) +
  geom_point(data = rho_dt_long[id == id_max & variable %in% seq(1, 20, by = 2)], inherit.aes = FALSE, aes(x = variable, y = value, colour = "Worst Case")) +
  geom_line(data = rho_dt_long[id == id_min & variable %in% seq(1, 20, by = 2)], inherit.aes = FALSE, aes(x = variable, y = value, colour = "Best Case")) +
  geom_line(data = rho_dt_long[id == id_max & variable %in% seq(1, 20, by = 2)], inherit.aes = FALSE, aes(x = variable, y = value, colour = "Worst Case"))









# Plot 2: -----------------------------------------------------------------
tst <- learn_pca(Y = PH)
Ystar <- tst$Encode(Y = PH, k = 9)

Sigma <- cov(Ystar)
Ystar_sim <- mvtnorm::rmvnorm(n = 100, sigma = Sigma)
Yhat_sim <- tst$Decode(Ystar = Ystar_sim)
matplot(t(Yhat_sim), type = "l")
dev.off()

dim(PH)
loss_w_sim <- matrix(NA, nrow = nrow(PH), ncol = 100)

for(i in 1:nrow(PH)) {
  print(i)
  y <- PH[i, ]
  for(j in 1:100) {
    print(j)
    yhat <- Yhat_sim[j, ]
    loss_w_sim[i, j] <- GLarE:::get_one_minus_squared_correlation(observed = y, predicted = yhat)
  }
}

av_cor_w_sim <- apply(loss_w_sim, 1, mean)
plot(av_cor_w_sim, ph_pca$rho_v[, 9])


dt <- data.table(loss = ph_pca$rho_v[, 9], av_sim = av_cor_w_sim)
p2 <- ggplot(dt) +
  aes(x = av_sim, y = loss) +
  geom_point(colour = "grey", alpha = 0.5) +
  labs(x = expression("Similarity with Simulated Data"),
       y = expression("Information Loss: 1 - Sq. Cor" ~ (1 - rho^2)),
       title = "Similarity to Simulated Observations") +
  scale_y_continuous(limits = c(0, 1), breaks = c(0, 0.5, 1), labels = c("0 = Lossless", "0.5", "1 = No Information")) +
  geom_point(data = dt[id_min], mapping = aes(colour = "Best Case"), size = 3, pch = 15) +
  geom_point(data = dt[id_max], mapping = aes(colour = "Worst Case"), size = 3, pch = 15) +
  scale_colour_manual(values = c("darkgreen", "cornflowerblue")) +
  theme(text = element_text(size = 14, family = "sans"),
        axis.title = element_text(size = 14),
        legend.title = element_blank(),
        axis.title.y = element_text(margin = margin(t = 0, r = - 20, b = 0, l = 0, unit = "pt")),
        plot.title = element_text(size = 15),
        legend.position = c(0.25, 0.85),
        legend.text = element_text(size = 15),
        legend.background = element_rect(colour = "black"))


ggpubr::ggarrange(p1, p2, nrow = 2)
ggsave(filename = "figures/info-loss-02.pdf", device = "pdf", width = 13 * 0.825, height = 2 * 8 * 0.685)
