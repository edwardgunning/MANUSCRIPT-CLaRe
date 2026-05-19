se_binom <- function(phat, n) {
  sqrt((phat * (1-phat))/n)
}

sample_normal <- function(mu_mu, sigma_mu, mu_log_sigma, sigma_log_sigma, nobs = 500) {
  mu <- rnorm(n = 1, mean = mu_mu, sd = sigma_mu)
  sigma <- exp(rnorm(n = 1, mean = mu_log_sigma, sd = sigma_log_sigma))

  x <- rnorm(n = nobs, mean = mu, sd = sigma)
  q <- sort(x)
  list(x = x, q = q)
}



sample_skewnormal <- function(mu_mu,
                              sigma_mu,
                              mu_log_sigma,
                              sigma_log_sigma,
                              mu_alpha,
                              sigma_alpha,
                              nobs = 500) {
  # random hierarchical parameters
  mu <- rnorm(1, mean = mu_mu, sd = sigma_mu)
  sigma <- exp(rnorm(1, mean = mu_log_sigma, sd = sigma_log_sigma))
  alpha <- rnorm(1, mean = mu_alpha, sd = sigma_alpha)
  delta <- alpha/ sqrt(1 + alpha^2)

  omega_sq <- sigma^2 / (1 - ((2 * delta^2) / pi))
  omega <- sqrt(omega_sq)

  xi <- mu - omega * delta * sqrt(2/pi)


  x <- sn::rsn(n = nobs, xi = xi, omega = omega, alpha = alpha)

  list(
    mu = mu,
    sigma = sigma,
    alpha = alpha,
    x = x,
    q = sort(x)
  )
}


sample_skewnormal <- function(mu_mu,
                              sigma_mu,
                              mu_log_sigma,
                              sigma_log_sigma,
                              mu_alpha,
                              sigma_alpha,
                              nobs = 500) {
  # random hierarchical parameters
  mu <- rnorm(1, mean = mu_mu, sd = sigma_mu)
  sigma <- exp(rnorm(1, mean = mu_log_sigma, sd = sigma_log_sigma))
  alpha <- rnorm(1, mean = mu_alpha, sd = sigma_alpha)
  delta <- alpha/ sqrt(1 + alpha^2)

  omega_sq <- sigma^2 / (1 - ((2 * delta^2) / pi))
  omega <- sqrt(omega_sq)

  xi <- mu - omega * delta * sqrt(2/pi)


  x <- sn::rsn(n = nobs, xi = xi, omega = omega, alpha = alpha)

  list(
    mu = mu,
    sigma = sigma,
    alpha = alpha,
    x = x,
    q = sort(x)
  )
}

sample_skewnormal_02 <- function(mu_mu,
                              sigma_mu,
                              mu_log_sigma,
                              sigma_log_sigma,
                              mu_alpha,
                              sigma_alpha,
                              nobs = 500) {
  # random hierarchical parameters
  mu <- rnorm(1, mean = mu_mu, sd = sigma_mu)
  sigma <- exp(rnorm(1, mean = mu_log_sigma, sd = sigma_log_sigma))

  m <- mu_alpha
  v <- sigma_alpha^2

  sigma_log_sq <- log(1 + v / m^2)
  sigma_log <- sqrt(sigma_log_sq)
  mu_log <- log(m) - 0.5 * sigma_log_sq

  alpha <- exp(rnorm(1, mean = mu_log, sd = sigma_log))
  delta <- alpha/ sqrt(1 + alpha^2)

  omega_sq <- sigma^2 / (1 - ((2 * delta^2) / pi))
  omega <- sqrt(omega_sq)

  xi <- mu - omega * delta * sqrt(2/pi)


  x <- sn::rsn(n = nobs, xi = xi, omega = omega, alpha = alpha)

  list(
    mu = mu,
    sigma = sigma,
    alpha = alpha,
    x = x,
    q = sort(x)
  )
}




ccc <- function(observed, predicted, na.rm = FALSE) {
  if (length(observed) != length(predicted)) {
    stop("observed and predicted must have the same length.")
  }

  if (na.rm) {
    keep <- stats::complete.cases(observed, predicted)
    observed <- observed[keep]
    predicted <- predicted[keep]
  }

  if (length(observed) < 2) {
    stop("Need at least 2 paired observations.")
  }

  mobserved <- mean(observed)
  mpredicted <- mean(predicted)
  vobserved <- stats::var(observed)
  vpredicted <- stats::var(predicted)
  cobservedpredicted <- stats::cov(observed, predicted)

  2 * cobservedpredicted / (vobserved + vpredicted + (mobserved - mpredicted)^2)
}

get_one_minus_squared_ccc <- function(predicted, observed) {
  1 - ccc(observed, predicted)^2
}
