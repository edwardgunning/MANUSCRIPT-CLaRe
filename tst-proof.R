tst <- prcomp(USArrests)  # inappropriate
Phi <- tst$rotation[, 1:3]

X <- as.matrix(USArrests)

n_replicates <- nrow(X)

# Initialize results
results <- data.frame(
  replicate = 1:n_replicates,
  one_minus_r_squared = numeric(n_replicates),
  d_squared_ratio = numeric(n_replicates)
)

# Simulation loop
for (i in 1:n_replicates) {
  print(i)
  # Generate random x and center it
  x <- X[i, ]
  x_c <- x - mean(x)

  # Generate random orthonormal Phi
  P <- Phi %*% t(Phi)  # Projection matrix

  # Project x_c onto the subspace
  y_c <- P %*% x_c

  # Compute r^2 (squared Pearson correlation)
  r_squared <- (sum(x_c * y_c)^2) / (sum(x_c^2) * sum(y_c^2))

  # Compute 1 - r^2
  one_minus_r_squared <- 1 - r_squared

  # Compute d^2 and its ratio to norm
  d_squared <- sum((x_c - y_c)^2)
  d_squared_ratio <- d_squared / sum(x_c^2)

  # Store results
  results$one_minus_r_squared[i] <- one_minus_r_squared
  results$d_squared_ratio[i] <- d_squared_ratio
}


# Plot 1 - r^2 vs. d^2 / ||x_c||^2
plot(
  results$one_minus_r_squared, results$d_squared_ratio
)
abline(a = 0, b = 1, col = "red", lty = 2)  # Add y = x line for reference


