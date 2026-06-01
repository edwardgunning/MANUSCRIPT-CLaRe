# Load packages and functions: --------------------------------------------
source(here::here("code", "additional-helpers-for-quantiles.R"))
library(GLaRe)

# Setting: ----------------------------------------------------------------
nsim <- 1000
mu_mu_1 <- 0
sigma_mu_1 <- 5
mu_log_sigma_1 <- 0
sigma_log_sigma_1 <- 1
mu_alpha_2 <- 6
sigma_alpha_2 <- 3

# aside... for reporting:
####
# mu alpha and sigma_alpha were actually mean and variance
# on exponentiation scale:
sigma_log_sq <- log(1 + sigma_alpha_2^2 / mu_alpha_2^2)
sigma_log <- sqrt(sigma_log_sq)
mu_log <- log(mu_alpha_2) - 0.5 * sigma_log_sq
mu_log
sigma_log
####

n_1 <- 100
n_2 <- 50
group <- c(rep(1, times = n_1), rep(2, times = n_2))

qd_1 <- qd_2 <- p_vals_qd_1 <- p_vals_qd_2 <- vector(mode = "numeric", length = nsim)

set.seed(1)
for (b in 1:nsim) {
  print(b)
  Q_1 <- sapply(seq_len(n_1),
    FUN = function(x) {
      sample_normal(
        mu_mu = mu_mu_1,
        sigma_mu = sigma_mu_1,
        mu_log_sigma = mu_log_sigma_1,
        sigma_log_sigma = sigma_log_sigma_1
      )$q
    }
  )
  Q_2 <- sapply(seq_len(n_2),
    FUN = function(x) {
      sample_skewnormal_02(
        mu_mu = mu_mu_1,
        sigma_mu = sigma_mu_1,
        mu_log_sigma = mu_log_sigma_1,
        sigma_log_sigma = sigma_log_sigma_1,
        mu_alpha = mu_alpha_2,
        sigma_alpha = sigma_alpha_2
      )$q
    }
  )

  # TO DO --- CAPTURE HOW MANY RETAINED
  Q_full <- cbind(Q_1, Q_2)
  pca_q <- prcomp(t(Q_full))
  (pca_fve <- cumsum(pca_q$sdev^2) / sum(pca_q$sdev^2))
  qd_2[b] <- min(which(pca_fve > 0.99))

  gl1 <- GLaRe(mat = t(Q_full), latent_dim_to = 5, kf = n_1 + n_2, loss_function = get_one_minus_squared_ccc, verbose = FALSE)
  qd_1[b] <- gl1$qd

  scores <- pca_q$x
  p_vals_qd_1[b] <- Hotelling::hotelling.test(scores[group == 1, 1:qd_1[b]], scores[group == 2, 1:qd_1[b]], var.equal = FALSE)$pval
  p_vals_qd_2[b] <- Hotelling::hotelling.test(scores[group == 1, 1:qd_2[b]], scores[group == 2, 1:qd_2[b]], var.equal = FALSE)$pval
}


pdf(
  here::here(
    "figures",
    "skew-simulation-boxplot.pdf"
  ),
  width = 5,
  height = 5
)
par(mfrow = c(1, 1))
boxplot(cbind(p_vals_qd_1, p_vals_qd_2),
  names = c(
    paste0("CLaRe, Power = ", 100 * mean(p_vals_qd_1 < 0.05), "%"),
    paste0("PVE, Power = ", 100 * mean(p_vals_qd_2 < 0.05), "%")
  ),
  ylab = "p-value from Hotelling's test"
)
title("Boxplot of p-values from Simulation")
abline(h = 0.05, col = "brown4", lwd = 1, lty = 2)
dev.off()



(phat_1 <- round(mean(p_vals_qd_1 < 0.05), 2))
(se_phat_1 <- round(se_binom(phat_1, nsim), 2))

(phat_2 <- round(mean(p_vals_qd_2 < 0.05), 2))
(se_phat_2 <- round(se_binom(phat_2, nsim), 2))

# Save results
saveRDS(
  list(
    p_vals_qd_1 = p_vals_qd_1,
    p_vals_qd_2 = p_vals_qd_2
  ),
  file = here::here("data", "quantile-function-simulation-results.rds")
)
# Checksums:
(md5s <- tools::md5sum(here::here(
  "data",
  "quantile-function-simulation-results.rds"
)))

writeLines(
  paste(names(md5s), md5s),
  here::here("data", "quantile-function-simulation-results_md5.txt")
)
# -------------------------------------------------------------------------

set.seed(1)
Q_1 <- sapply(seq_len(100),
  FUN = function(x) {
    sample_normal(
      mu_mu = mu_mu_1,
      sigma_mu = sigma_mu_1,
      mu_log_sigma = mu_log_sigma_1,
      sigma_log_sigma = sigma_log_sigma_1
    )$q
  }
)
Q_2 <- sapply(seq_len(100),
  FUN = function(x) {
    sample_skewnormal_02(
      mu_mu = mu_mu_1,
      sigma_mu = sigma_mu_1,
      mu_log_sigma = mu_log_sigma_1,
      sigma_log_sigma = sigma_log_sigma_1,
      mu_alpha = mu_alpha_2,
      sigma_alpha = sigma_alpha_2
    )$q
  }
)


pdf(here::here("figures", "skew-normal-data-generation.pdf"), width = 8, height = 8)
par(cex = 1.25)
layout(matrix(
  c(
    1, 1, 1, 2, 2, 2,
    3, 3, 4, 4, 5, 5
  ),
  nrow = 2, byrow = TRUE
))
matplot(Q_1,
  type = "l",
  ylim = c(range(Q_1, Q_2)),
  col = scales::alpha("red4", 0.5),
  lty = 1,
  xlab = "p", ylab = "Q(p)", main = "Normal Group"
)
matplot(Q_2,
  type = "l", ylim = c(range(Q_1, Q_2)), col = scales::alpha(4, 0.5), lty = 1,
  xlab = "p", ylab = "Q(p)", main = "Skew-normal Group"
)

boxplot(
  cbind(
    apply(Q_1, 2, mean),
    apply(Q_2, 2, mean)
  ),
  col = c("red4", 4),
  names = c("N", "SN")
)
title("Means")
boxplot(
  log(cbind(
    apply(Q_1, 2, var),
    apply(Q_2, 2, var)
  )),
  col = c("red4", 4),
  names = c("N", "SN")
)
title("Log of Variances")
boxplot(
  cbind(
    apply(Q_1, 2, e1071::skewness),
    apply(Q_2, 2, e1071::skewness)
  ),
  col = c("red4", 4),
  names = c("N", "SN")
)
title("Skewness")
dev.off()
