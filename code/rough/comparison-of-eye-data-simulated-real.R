library(GLarE)
library(ggplot2)

eye1 <- as.matrix(glaucoma_data) # simulated copy
eye2 <- as.matrix(read.table(file = "data/Y_raw.txt")) # data

plot_eye(y = eye1[1, ])
plot_eye(y = eye2[1, ])

# plot averages:
plot_eye(y = apply(eye1, 2, mean))
plot_eye(y = apply(eye2, 2, mean))

#
hist(eye1)
hist(log(eye2))
hist(log(eye2[eye2<=10]))


plot_eye <- function(y) {
  # Validate input
  if (!(is.numeric(y) & length(y) == 120 * 120)) stop("y must be a numeric vector of the correct length")

  # Prepare data for plotting
  plot_df <- data.frame(
    y = y,
    theta = rep(seq(0, 360, length.out = 120), each = 120),
    phi = rep(seq(9, 24, length.out = 120), times = 120)
  )

  # Create radial plot
  ggplot2::ggplot(data = plot_df) +
    ggplot2::aes(x = theta, y = phi) +
    ggplot2::coord_radial(inner.radius = 9 / 24, expand = FALSE) +
    ggplot2::geom_tile(mapping = aes(fill = y)) +
    ggplot2::scale_fill_gradientn(colours = rainbow(8), limits = c(-0.352333, 2.020408), oob = scales::squish) +
    ggplot2::labs(fill = expression(X[i](theta, phi)), x = expression(theta), y = expression(phi))
}

plot_eye_2 <- function(y) {
  # Validate input
  if (!(is.numeric(y) & length(y) == 120 * 120)) stop("y must be a numeric vector of the correct length")

  # Prepare data for plotting
  plot_df <- data.frame(
    y = y,
    theta = rep(seq(0, 360, length.out = 120), each = 120),
    phi = rep(seq(9, 24, length.out = 120), times = 120)
  )

  # Create radial plot
  ggplot2::ggplot(data = plot_df) +
    ggplot2::aes(x = theta, y = phi) +
    ggplot2::coord_radial(inner.radius = 9 / 24, expand = FALSE) +
    ggplot2::geom_tile(mapping = aes(fill = y)) +
    ggplot2::scale_fill_gradientn(colours = rainbow(8), trans = "sqrt", limits = c(0, 4), oob = scales::squish) + #, oob = scales::squish, trans = "log") +
    ggplot2::labs(fill = expression(X[i](theta, phi)), x = expression(theta), y = expression(phi))
}

hist(sqrt(eye2[eye2<=20]))
abline(v = 4)
plot_eye(eye2[269,])
plot_eye_2(eye2[1,])

hist(eye2[304,])
order(apply(eye2, 1, var))

any(is.nan(log(eye2)))
any(eye2 == 0)
