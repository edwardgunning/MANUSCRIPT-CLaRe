# Load packages and functions: --------------------------------------------
library(ggplot2)
source(here::here("code", "additional-helpers-for-quantiles.R"))
source(here::here("code", "theme_gunning.R"))
library(GLaRe)


# Setting: ----------------------------------------------------------------
# This time we'll vary some,
nsim_per_setting <- 500
mu_mu_1 <- 0
sigma_mu_1 <- 5
mu_log_sigma_1 <- 0
sigma_log_sigma_1 <- 1
mu_alpha_2_levels <- c(2, 4, 6, 8, 10)
sigma_alpha_2 <- 3
nobs <- 500
n_1 <- 100
n_2_levels <- c(50, 100, 150)

simulation_settings <- expand.grid(
  sim_rep = seq_len(nsim_per_setting),
  mu_alpha_2 = mu_alpha_2_levels,
  n_2 = n_2_levels
)
nsim <- nrow(simulation_settings)
qd_1 <- qd_2 <- qd_3 <- p_vals_qd_1 <- p_vals_qd_2 <- p_vals_qd_3 <- vector(mode = "numeric", length = nsim)
eigen_vecs <- array(NA, c(nobs, 3, nsim))
sd_vec <- mu_vec <- array(NA, c(nobs, 2, nsim))
keep_all_threshold <- 10^-(5)
max_testable_k <- n_1 + max(n_2_levels) - 2
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
  n_2 <- simulation_settings[b, "n_2"]
  group <- c(rep(1, times = n_1), rep(2, times = n_2))
  mu_alpha_2 <- simulation_settings[b, "mu_alpha_2"]
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

  mu_vec[, 1, b] <- apply(Q_1, MARGIN = 1, mean)
  mu_vec[, 2, b] <- apply(Q_2, MARGIN = 1, mean)

  sd_vec[, 1, b] <- apply(Q_1, MARGIN = 1, sd)
  sd_vec[, 2, b] <- apply(Q_2, MARGIN = 1, sd)

  # TO DO --- CAPTURE HOW MANY RETAINED
  Q_full <- cbind(Q_1, Q_2)
  pca_q <- prcomp(t(Q_full))
  # traditional and keep-all rules
  lambda <- pca_q$sdev^2
  (pca_fve <- cumsum(lambda) / sum(lambda))
  qd_2[b] <- min(which(pca_fve > 0.99))
  qd_3[b] <- max(which(lambda > keep_all_threshold))

  gl1 <- GLaRe(
    mat = t(Q_full),
    latent_dim_to = 7,
    kf = n_1 + n_2,
    loss_function = get_one_minus_squared_ccc, verbose = FALSE
  )
  qd_1[b] <- gl1$qd

  scores <- pca_q$x
  p_vals_qd_1[b] <- Hotelling::hotelling.test(scores[group == 1, 1:qd_1[b]], scores[group == 2, 1:qd_1[b]], var.equal = FALSE)$pval
  p_vals_qd_2[b] <- Hotelling::hotelling.test(scores[group == 1, 1:qd_2[b]], scores[group == 2, 1:qd_2[b]], var.equal = FALSE)$pval
  p_vals_qd_3[b] <- Hotelling::hotelling.test(scores[group == 1, 1:qd_3[b]], scores[group == 2, 1:qd_3[b]], var.equal = FALSE)$pval

  eigen_vecs[, , b] <- pca_q$rotation[, 1:3]

  # Store p-values across all testable dimensions for this setting.
  setting_max_testable_k <- n_1 + n_2 - 2
  p_vals_by_k[b, seq_len(setting_max_testable_k)] <- vapply(
    seq_len(setting_max_testable_k),
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


# Examine Results: --------------------------------------------------------
## table ------------------------------------------------------------------
library(data.table)
simulation_results <- data.table(simulation_settings, qd_1, p_vals_qd_1, qd_2, p_vals_qd_2, qd_3, p_vals_qd_3)
summary_results <- simulation_results[, .(
  reject_clare = mean(p_vals_qd_1 < 0.05),
  reject_pve = mean(p_vals_qd_2 < 0.05)
),
by = .(mu_alpha_2, n_2)
]
summary_results

summary_results_table <- data.table::copy(summary_results)
summary_results_table[, reject_clare := sprintf("%.1f\\%%", 100 * reject_clare)]
summary_results_table[, reject_pve := sprintf("%.1f\\%%", 100 * reject_pve)]
data.table::setnames(
  summary_results_table,
  c("mu_alpha_2", "n_2", "reject_clare", "reject_pve"),
  c("$\\mu_{\\alpha}$", "$n_2$", "CLaRe", "PVE")
)

sensitivity_summary_tabular <- knitr::kable(
  summary_results_table,
  format = "latex",
  booktabs = TRUE,
  escape = FALSE,
  row.names = FALSE,
  align = rep("r", 4),
  caption = NULL
)

sensitivity_summary_tabular <- kableExtra::add_header_above(
  sensitivity_summary_tabular,
  c("Simulation setting" = 2, "Power" = 2),
  escape = FALSE
)

sensitivity_summary_latex <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Estimated power of CLaRe and the proportion of variance explained (PVE) selection rule in the sensitivity analysis.}",
  "\\label{tab:quantile-sensitivity-analysis}",
  sensitivity_summary_tabular,
  "\\end{table}"
)

writeLines(
  sensitivity_summary_latex,
  here::here("tables", "quantile-sensitivity-analysis-table.tex")
)



simulation_results_2 <- data.table(simulation_settings, p_vals_by_k)
simulation_results_2_lng <- melt.data.table(simulation_results_2,
                                            id.vars = c('sim_rep', "mu_alpha_2", "n_2"),
                                            variable.name = "K", variable.factor = FALSE,
                                            value.name = "p_value")
simulation_results_2_lng[, K := as.numeric(stringr::str_remove(K, "K_"))]
simulation_results_2_lng_summ <- simulation_results_2_lng[, .(power = mean(p_value < 0.05, na.rm = TRUE)),
                         by = .(mu_alpha_2, n_2, K)]
ggplot(data = simulation_results_2_lng_summ) +
  aes(x = K, y = power, colour = factor(mu_alpha_2, ordered = TRUE),
      pch = factor(n_2)) +
  geom_point() +
  geom_line() +
  labs(colour = expression(mu[alpha]~":"),
       linetype = expression(n[2]~":"),
       pch =expression(n[2]~":"),
       y = "Power",
       x = "Retained K",
       title = "Power in extended simulation",
       subtitle = expression("Across all possible retained"~K)) +
  theme(legend.position = 'bottom',
        text = element_text(size = 15, hjust = 0.5),
        plot.title = element_text(size = 15, hjust= 0),
        axis.title = element_text(size = 15))
ggsave(filename = here::here("figures", "sensitivity-analysis-power-by-K.pdf"),
       width = 6.25, height = 5.25)
