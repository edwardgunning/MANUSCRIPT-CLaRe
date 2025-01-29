# ------------------------------------------------------------------------#
# Script to make initial plot of the datasets used in the analysis.
# ------------------------------------------------------------------------#

# -------------------------------------------------------------------------
library(GLarE)
library(ggplot2)
# -------------------------------------------------------------------------

eye <- as.matrix(read.table(file = "data/Y_outlier_removed.txt"))
mnist <- keras::dataset_mnist()
plot_mnist(mnist$train$x[8, , ])


load("data/proteomic_gels.RData")
gels.data <- aperm(gels.data, perm = c(3, 2, 1))
plot_gel <- function(y) {
  image(x = seq(0, 1, length.out = 861), y = seq(0, 1, length.out = 646), z = y, col = topo.colors(10), xlab = NA, ylab = NA)
}


pdf(file = "figures/data-plot.pdf", width = 12, height = 4)
par(mfrow = c(1, 3))
plot.new()
vps <- gridBase::baseViewports()
grid::pushViewport(vps$figure)
vp1 <- grid::plotViewport(c(-2, -1, -1, -1))
print(
  plot_eye(eye[1, ]) +
    ggtitle("(a)") +
    theme(plot.title = element_text(
      hjust = 0.5,
      margin = margin(b = 15, t = -20),
      size = 10, face = "bold"
    )),
  vp = vp1
)
plot_gel(y = gels.data[1, , ])
title("(b)")
plot_mnist(mnist$train$x[10, , ], main = "(c)")
title(main = "(c)")
dev.off()
