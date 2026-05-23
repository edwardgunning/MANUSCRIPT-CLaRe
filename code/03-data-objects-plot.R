# ------------------------------------------------------------------------#
# Script to make initial plot of the datasets used in the analysis.
# ------------------------------------------------------------------------#

# Load packages: ----------------------------------------------------------
source("load_Python_legacy_env.R")
# ------------------------------------------------------------------------#
library(GLaRe)
library(ggplot2)
# ------------------------------------------------------------------------#

# Read in EYE: ------------------------------------------------------------
eye <- as.matrix(read.table(file = "data/Y_outlier_removed.txt"))

# ------------------------------------------------------------------------#
# ------------------------------------------------------------------------#

# Read in MNIST (stored copy) ---------------------------------------------
mnist <- readRDS(file = "data/mnist_external_data.rds")$data

# ------------------------------------------------------------------------#
# ------------------------------------------------------------------------#


# Read in and re-organize Gels data. --------------------------------------
load("data/proteomic_gels.RData")
gels.data <- aperm(gels.data, perm = c(3, 2, 1))
# ------------------------------------------------------------------------#
# ------------------------------------------------------------------------#



# Create and Save Plot: ---------------------------------------------------
pdf(file = "figures/data-plot.pdf", width = 12, height = 4.5)
par(mfrow = c(1, 3), cex = 1.1, xpd = T)
plot.new()
vps <- gridBase::baseViewports()
grid::pushViewport(vps$figure)
vp1 <- grid::plotViewport(c(-2, -1, -1, -1))
print(
  GLaRe::plot_eye(eye[1, ]) +
    ggtitle("(a)") +
    theme(
      text = element_text(size = 16),
      panel.border = element_blank(),
      plot.margin = margin(10, 10, 10, 20), # Adjust left margin if Y label is clipped
      axis.title.y = element_text(margin = margin(r = 10)),
      axis.title = element_text(size = 16),
      legend.text = element_text(size = 10),
      plot.title = element_text(
        hjust = 0.5,
        margin = margin(b = 50, t = -30), # , t = -20),
        size = 16, face = "bold"
      )
    ),
  vp = vp1
)
plot_gel(y = gels.data[1, , ])
title("(b)")
plot_mnist(mnist$train$x[10, , ], main = "(c)")
title(main = "(c)")
dev.off()
