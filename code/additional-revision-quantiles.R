# Load packages and functions: --------------------------------------------
source(here::here("code", "additional-helpers-for-quantiles.R"))
source(here::here("code", "theme_gunning.R"))
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
nobs <- 500
n_1 <- 100
n_2 <- 50
group <- c(rep(1, times = n_1), rep(2, times = n_2))
qd_1 <- qd_2 <- qd_3 <- qd_4 <- p_vals_qd_1 <- p_vals_qd_2 <- p_vals_qd_3 <- vector(mode = "numeric", length = nsim)
eigen_vecs <- array(NA, c(nobs, 3, nsim))
max_testable_k <- n_1 + n_2 - 2
p_vals_by_k <- matrix(
  NA_real_,
  nrow = nsim,
  ncol = max_testable_k,
  dimnames = list(NULL, paste0("K_", seq_len(max_testable_k)))
)

# RUN B = 1000 SIMULATION REPS. -------------------------------------------
set.seed(1)
for (b in 1:nsim) {
  print(b)
  Q_1 <- sapply(seq_len(n_1),
    FUN = function(x) {
      sample_normal(
        nobs = nobs,
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
        nobs = nobs,
        mu_mu = mu_mu_1,
        sigma_mu = sigma_mu_1,
        mu_log_sigma = mu_log_sigma_1,
        sigma_log_sigma = sigma_log_sigma_1,
        mu_alpha = mu_alpha_2,
        sigma_alpha = sigma_alpha_2
      )$q
    }
  )

  Q_full <- cbind(Q_1, Q_2)
  pca_q <- prcomp(t(Q_full))

  # traditional and keep-all rules
  lambda <- pca_q$sdev^2
  (pca_fve <- cumsum(lambda) / sum(lambda))
  qd_2[b] <- min(which(pca_fve > 0.99))

  # CLaRe selection
  gl1 <- GLaRe(
    mat = t(Q_full),
    latent_dim_to = 5,
    kf = n_1 + n_2,
    loss_function = get_one_minus_squared_ccc,
    verbose = FALSE
  )
  qd_1[b] <- gl1$qd

  # Reviewer wanted to know how many components
  # were needed to make average ccc below 0.05 (rather than 95th percentile)
  mean_loss <- apply(gl1$rho_v, 2, mean)
  qd_4[b] <- min(which(mean_loss < 0.05))

  scores <- pca_q$x
  p_vals_qd_1[b] <- Hotelling::hotelling.test(scores[group == 1, 1:qd_1[b]], scores[group == 2, 1:qd_1[b]], var.equal = FALSE)$pval
  p_vals_qd_2[b] <- Hotelling::hotelling.test(scores[group == 1, 1:qd_2[b]], scores[group == 2, 1:qd_2[b]], var.equal = FALSE)$pval
  # Now just use all PCs
  k_qd_3 <- max_testable_k
  repeat {
    hotelling_qd_3 <- tryCatch(
      Hotelling::hotelling.test(
        scores[group == 1, seq_len(k_qd_3), drop = FALSE],
        scores[group == 2, seq_len(k_qd_3), drop = FALSE],
        var.equal = FALSE
      ),
      error = identity
    )

    if (!inherits(hotelling_qd_3, "error")) {
      break
    }
    if (!grepl("computationally singular", conditionMessage(hotelling_qd_3), fixed = TRUE)) {
      stop(hotelling_qd_3)
    }

    k_qd_3 <- k_qd_3 - 1L
  }

  qd_3[b] <- k_qd_3
  p_vals_qd_3[b] <- hotelling_qd_3$pval

  eigen_vecs[, , b] <- pca_q$rotation[, 1:3]

  # Store p-values across all candidate dimensions for the power curve.
  p_vals_by_k[b, ] <- vapply(
    seq_len(max_testable_k),
    FUN.VALUE = numeric(1),
    FUN = function(k) {
      tryCatch(
        Hotelling::hotelling.test(
          scores[group == 1, seq_len(k), drop = FALSE],
          scores[group == 2, seq_len(k), drop = FALSE],
          var.equal = FALSE
        )$pval,
        error = function(e) {
          if (grepl("computationally singular", conditionMessage(e), fixed = TRUE)) {
            return(NA_real_)
          }
          stop(e)
        }
      )
    }
  )
}


# Quick Summary and Store of Results: -------------------------------------
reject_1 <- p_vals_qd_1 < 0.05
reject_2 <- p_vals_qd_2 < 0.05
reject_3 <- p_vals_qd_3 < 0.05

mean(reject_1)
mean(reject_2)
mean(reject_3)

saveRDS(object = list(
  rejects = c(reject_1 = reject_1, reject_2 = reject_2, reject_3 = reject_3),
  p_vals = c(p_vals_qd_1 = p_vals_qd_1, p_vals_qd_2 = p_vals_qd_2, p_vals_qd_3 = p_vals_qd_3),
  qds = c(qd_1 = qd_1, qd_2 = qd_2, qd_2 = qd_3)
), file = here::here("data", "addiional-simulation-quantiles-results.rds"))


pdf(file = here::here("figures", "power-vs-K.pdf"), width = 8, height = 5)
power_hat <- apply(p_vals_by_k < 0.05, 2, mean, na.rm = FALSE)
plot(power_hat, pch = 20, cex = 0.5, ylab = "Power", xlab = "Retained K")
dev.off()
# TABLE OF RESULTS: -------------------------------------------------------

make_qd_summary <- function(qd, reject, label, dims) {
  selected <- table(factor(qd, levels = dims))
  rejected <- tapply(reject, factor(qd, levels = dims), sum)
  rejected[is.na(rejected)] <- 0

  data.frame(
    latent_dimension = dims,
    approach = label,
    selected = as.integer(selected),
    rejected = as.integer(rejected),
    rejection_rate = ifelse(selected > 0, rejected / selected, NA_real_),
    check.names = FALSE
  )
}

qd_dims <- sort(unique(c(qd_1, qd_2)))
qd_summary <- rbind(
  make_qd_summary(qd_1, reject_1, "CLaRe", qd_dims),
  make_qd_summary(qd_2, reject_2, "PVE", qd_dims)
)

qd_summary_wide <- reshape(
  qd_summary,
  idvar = "latent_dimension",
  timevar = "approach",
  direction = "wide"
)

qd_summary_wide <- qd_summary_wide[, c(
  "latent_dimension",
  "selected.CLaRe", "rejection_rate.CLaRe",
  "selected.PVE", "rejection_rate.PVE"
)]

names(qd_summary_wide) <- c(
  "$K$",
  "Selected", "Rejection rate",
  "Selected", "Rejection rate"
)

qd_summary_wide[, c(3, 5)] <- lapply(
  qd_summary_wide[, c(3, 5)],
  function(x) ifelse(is.na(x), "--", sprintf("%.1f\\%%", 100 * x))
)

qd_summary_wide

qd_summary_tabular <- knitr::kable(
  qd_summary_wide,
  format = "latex",
  booktabs = TRUE,
  escape = FALSE,
  row.names = FALSE,
  align = rep("r", 5),
  caption = NULL
)

qd_summary_tabular <- kableExtra::add_header_above(
  qd_summary_tabular,
  c(" " = 1, "CLaRe" = 2, "PVE" = 2),
  escape = FALSE
)

qd_summary_latex <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Number of simulation replicates selecting each latent dimension and rejection rate, i.e., percentage of times the null hypothesis was correctly rejected, by selection rule.}",
  "\\label{tab:quantile-selection-rejection}",
  qd_summary_tabular,
  "\\end{table}"
)


writeLines(
  qd_summary_latex,
  here::here(
    "tables",
    "quantile-selection-rejection-table.tex"
  )
)
qd_summary_latex


# PlOT OF RESULTS: --------------------------------------------------------
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

# Plot EIGENVECTORS -------------------------------------------------------

flip_function <- function(given, target) {
  if (sum((given - target)^2) > sum((given + target)^2)) {
    return(-given)
  } else {
    return(given)
  }
}


eigen_vecs_flipped <- eigen_vecs
# phi 1:
true_phi_1_vec <- rep(sqrt(1 / 500), 500)
eigen_vecs_flipped[, 1, ] <- apply(eigen_vecs_flipped[, 1, ],
  2,
  flip_function,
  target = true_phi_1_vec
)

# phi 2:
pseq <- (1:500) / (500 + 1)
true_phi_2_vec <- qnorm(pseq)
matplot(true_phi_2_vec, type = "l")

true_phi_2_vec_scaled <- true_phi_2_vec / sqrt(sum(true_phi_2_vec^2))

eigen_vecs_flipped[, 2, ] <- apply(eigen_vecs_flipped[, 2, ],
  2,
  flip_function,
  target = true_phi_2_vec_scaled
)

eigen_vecs_flipped[, 3, ] <- apply(eigen_vecs_flipped[, 3, ],
  2,
  flip_function,
  target = eigen_vecs_flipped[, 3, 1]
)


pdf(
  file = here::here(
    "figures",
    "skew-simulation-eigenfunctions.pdf"
  ),
  width = 11.5, height = 4
)
par(mfrow = c(1, 3), cex = 1, mar = c(5, 6, 4, 1) + 0.05)
matplot(
  x = pseq, y = eigen_vecs_flipped[, 1, ],
  type = "l",
  xlab = expression(p),
  ylab = expression(hat(phi)[1](p)),
  lty = 1,
  col = scales::alpha("turquoise", 0.25)
)
lines(pseq, true_phi_1_vec, col = "black", lwd = 2)
legend("top", expression("True " ~ phi[1](p) ~ "=" ~ 1), col = 1, lty = 1)
title("First Eigenfunction")

matplot(
  x = pseq,
  y = eigen_vecs_flipped[, 2, ],
  type = "l",
  lty = 1,
  xlab = expression(p),
  ylab = expression(hat(phi)[2](p)),
  col = scales::alpha("turquoise", 0.25)
)
lines(pseq, true_phi_2_vec_scaled, col = "black", lwd = 2)
legend("top", expression("True " ~ phi[2](p) ~ "=" ~ Phi^-1 ~ (p)), col = 1, lty = 1)
title("Second Eigenfunction")

matplot(
  x = pseq,
  y = eigen_vecs_flipped[, 3, ],
  type = "l",
  lty = 1,
  xlab = expression(p),
  ylab = expression(hat(phi)[3](p)),
  col = scales::alpha("turquoise", 0.25)
)
title("Third Eigenfunction")
dev.off()


# Look at 1000th simulation run: ------------------------------------------

pdf(
  file = here::here("figures", "simulation-highlights-figure-01.pdf"),
  width = 13, height = 4
)
# First look at data:
par(mfrow = c(1, 3), cex = 0.9, mar = c(5, 6, 4, 1) + 0.05)
joint_ylims <- range(Q_full)
matplot(pseq,
  Q_1,
  xlab = expression(p),
  ylab = expression(Q(p)),
  type = "l",
  col = scales::alpha("red4", 0.25),
  lty = 1,
  ylim = joint_ylims
)
title("(a) Dataset from Normal Group")
matplot(pseq,
  Q_2,
  xlab = expression(p),
  ylab = expression(Q(p)),
  col = scales::alpha(4, 0.25),
  lty = 1,
  type = "l",
  ylim = joint_ylims
)
title("(b) Dataset from Skew-normal Group")
boxplot(cbind(p_vals_qd_1, p_vals_qd_2),
  names = c(
    paste0("CLaRe, Power = ", 100 * mean(p_vals_qd_1 < 0.05), "%"),
    paste0("PVE, Power = ", 100 * mean(p_vals_qd_2 < 0.05), "%")
  ),
  ylab = "p-value from Hotelling's test",
  cex.axis = 0.8
)
abline(h = 0.05, col = "darkgrey", lwd = 1, lty = 2)
title("(c) Boxplot of p-values from Simulation")
dev.off()

# and next line for highlights figure:

pdf(
  file = here::here(
    "figures",
    "simulation-highlights-figure-02.pdf"
  ),
  width = 11.5, height = 4
)
par(mfrow = c(1, 3), cex = 1, mar = c(5, 6, 4, 1) + 0.05)
matplot(
  x = pseq, y = eigen_vecs_flipped[, 1, ],
  type = "l",
  xlab = expression(p),
  ylab = expression(hat(phi)[1](p)),
  lty = 1,
  col = scales::alpha("turquoise", 0.25)
)
lines(pseq, true_phi_1_vec, col = "black", lwd = 2)
legend("top", expression("True " ~ phi[1](p) ~ "=" ~ 1), col = 1, lty = 1)
title("(d) First Eigenfunction")

matplot(
  x = pseq,
  y = eigen_vecs_flipped[, 2, ],
  type = "l",
  lty = 1,
  xlab = expression(p),
  ylab = expression(hat(phi)[2](p)),
  col = scales::alpha("turquoise", 0.25)
)
lines(pseq, true_phi_2_vec_scaled, col = "black", lwd = 2)
legend("top", expression("True " ~ phi[2](p) ~ "=" ~ Phi^-1 ~ (p)), col = 1, lty = 1)
title("(e) Second Eigenfunction")

matplot(
  x = pseq,
  y = eigen_vecs_flipped[, 3, ],
  type = "l",
  lty = 1,
  xlab = expression(p),
  ylab = expression(hat(phi)[3](p)),
  col = scales::alpha("turquoise", 0.25)
)
title("(f) Third Eigenfunction")
dev.off()


library(data.table)
library(ggplot2)
dt <- data.table(group, gl1$rho_v)
dt_long <- melt.data.table(
  data = dt, id.vars = "group",
  variable.name = "K", variable.factor = FALSE,
  value.name = "loss", value.factor = FALSE
)
dt_long[, K := as.numeric(stringr::str_remove(K, "V"))]
dt_long[, `:=`(group = factor(group))]

ggplot(dt_long[K %in% c(2, 3)], aes(
  x = factor(K),
  y = loss,
  color = group,
  fill = group
)) +
  scale_y_log10() +
  geom_boxplot(position = position_dodge(width = 0.8), alpha = 0.5, colour = "black") +
  labs(x = "K", y = expression("Loss " ~ epsilon ~ "(on " ~ log[10] ~ " scale)"), fill = "Group") +
  geom_hline(yintercept = 0.05, lty = 2) +
  scale_fill_manual(values = c("red4", 4), labels = c("Normal", "Skew-normal"), name = "Group:") +
  scale_x_discrete(labels = c("K = 2", "K = 3")) +
  theme_gunning() +
  theme(
    legend.position = "bottom",
    text = element_text(size = 14),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.title = element_text(face = "bold"),
    axis.text.x = element_text(size = 16)
  ) +
  ggtitle(label = expression("Individual Losses at " ~ K ~ "=" ~ 2 ~ "and " ~ K ~ "=" ~ 3))

ggsave(filename = here::here(
  "figures",
  "skew-simulation-losses.pdf"
), width = 6, height = 6)

# STORING RESULTS: --------------------------------------------------------
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


# ADDITIONAL EXAMPLE FOR FIGURE -------------------------------------------
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
