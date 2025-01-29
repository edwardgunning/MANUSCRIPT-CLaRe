library(GLarE)

eye1 <- as.matrix(glaucoma_data) # simulated copy
eye2 <- as.matrix(read.table(file = "data/Y_raw.txt")) # real dataset

# hist of dists:
hist(eye1)
hist(eye2)
hist((eye2)^(1/3))


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
    ggplot2::geom_tile(mapping = ggplot2::aes(fill = y)) +
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
    ggplot2::geom_tile(mapping = ggplot2::aes(fill = y)) +
    ggplot2::scale_fill_gradientn(colours = rainbow(8), limits = c(0, 4), oob = scales::squish, trans = "sqrt") +
    ggplot2::labs(fill = expression(X[i](theta, phi)), x = expression(theta), y = expression(phi))
}

plot_eye_3 <- function(y) {
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
    ggplot2::geom_tile(mapping = ggplot2::aes(fill = y)) +
    ggplot2::scale_fill_gradientn(colours = rainbow(8)) +
    ggplot2::labs(fill = expression(X[i](theta, phi)), x = expression(theta), y = expression(phi))
}


plot_eye(eye2[1,])
plot_eye_2(eye2[1,])

plot_eye(apply(eye1, 2, mean))
plot_eye_2(apply(eye2, 2, mean))

diff(order(-apply(eye2, 1, max)))

plot_eye_3(eye2[304,])
plot_eye_3(eye2[269,])
plot_eye_3(eye2[234,])
plot_eye_3(eye2[199,])

tst_cor <- cor(t(eye2))
dim(tst_cor)

apply(eye2[(which(apply(eye2, 1, function(x) any(x > 50)))),],1 , max)

inds <- 304 - seq(0, 8 * 35, by = 35)

max(eye2[inds,])
max(eye2[-inds, ])

max(eye2[164 - )])

heatmap(tst_cor)
image(tst_cor)

learn_dwt.2d()

