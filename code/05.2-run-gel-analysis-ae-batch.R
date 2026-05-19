k_seq <- seq(1, 53, by = 10)

for (ki in seq_along(k_seq)) {
  print(paste("Running iteration", ki))

  # Pass the iteration index as an argument to the worker script
  system(paste("Rscript code/05.3-run-gel-analysis-ae-worker.R", ki))

  # Optional: Add a delay between iterations
  Sys.sleep(1)
}
