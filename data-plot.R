# ------------------------------------------------------------------------#
# Script to make initial plot of the datasets used in the analysis.
# ------------------------------------------------------------------------#

# note: missing for now.

# -------------------------------------------------------------------------
library(GLarE)
library(ggplot2)
# -------------------------------------------------------------------------

eye <- as.matrix(glaucoma_data)
mnist <- keras::dataset_mnist()
plot_mnist(mnist$train$x[8,,])

pdf(file = "figures/data-plot.pdf", width = 12, height = 4)
par(mfrow = c(1, 3))
plot(0, 0, type = "n")
title("(a)")
plot.new()
vps <- gridBase::baseViewports()
grid::pushViewport(vps$figure)
vp1 <- grid::plotViewport(c(-2,-1,-1,-1))
print(plot_eye(eye[1,]) + ggtitle("(b)") + theme(plot.title = element_text(hjust = 0.5, margin = margin(b = 15, t = -20), size = 10, face = "bold")), vp = vp1)
plot_mnist(mnist$train$x[10,,], main = "(c)")
title(main = "(c)")
dev.off()
