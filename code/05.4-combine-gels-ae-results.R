library(GLarE)

k_seq <- seq(1, 53, by = 10)
file_names <- paste0("data/gels-ae-result-", k_seq, ".rds")
results_list <- lapply(file_names, readRDS)

results_list <- results_list[1:length(k_seq)]

combined_out <- results_list[[1]][["glare"]]
combined_out$rho_v <- sapply(results_list, function(x) x[["glare"]][["rho_v"]])
combined_out$Qrho_v <- sapply(results_list, function(x) x[["glare"]][["Qrho_v"]])
combined_out$corM_t <- sapply(results_list, function(x) x[["glare"]][["corM_t"]])
combined_out$corM_v <- sapply(results_list, function(x) x[["glare"]][["corM_v"]])
combined_out$breaks <- k_seq
combined_out$r <- combined_out$r <- length(k_seq)
combined_out$qd <- NA


GLarE:::summary_correlation_plot(combined_out,
  cvqlines = 0.9,
  attainment_rate = 0.95,
  tolerance_level = 0.05,
  method_name = "(c) AE",
  r = combined_out$r,
  q = combined_out$r,
  breaks = combined_out$breaks,
  qd = NA,
  show_legend = TRUE
)

combined_time <- round(sum(sapply(results_list, function(x) x[["time"]][["elapsed"]])) / 60, 1)
combined_time

saveRDS(object = combined_time, file = "data/gels-ae-time-combined.rds")
saveRDS(object = combined_out, file = "data/gels-ae-results-combined.rds")

