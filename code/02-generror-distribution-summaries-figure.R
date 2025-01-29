library(GLarE)
library(data.table)
library(ggplot2)
source("code/theme_gunning.R")
theme_gunning()

set.seed(1)
# Phoenome dataset:
PH_path <- "https://www.math.univ-toulouse.fr/~ferraty/SOFTWARES/NPFDA/npfda-phoneme.dat"
PH <- readr::read_table(file = PH_path, col_names = FALSE)
PH <- as.matrix(PH)[, 1:150]

ph_pca <- GLaRe(
  mat = PH,
  learn = "pca",
  kf = 5,
  latent_dim_by = 4,
  verbose = TRUE
)



library(plotly)
updated_heatmap <- ph_pca$heatmap %>%
  layout(
    xaxis = list(
      titlefont = list(size = 24), # X-axis title font size
      tickfont = list(size = 20) # X-axis tick text size
    ),
    yaxis = list(
      titlefont = list(size = 24), # Y-axis title font size
      tickfont = list(size = 20) # Y-axis tick text size
    )
  ) %>%
  style(
    colorbar = list(
      title = list(
        text = "Loss",
        font = list(size = 24)
      ),
      tickfont = list(size = 20) # ,
      # x = 0.5,                    # Position the color bar in the center horizontally (0 = left, 1 = right)
      # y = -0.2,                   # Position the color bar below the plot (adjust as needed)
      # len = 0.8,
      # orientation = "h"
    )
  )

plotly::export(updated_heatmap, file = "figures/phoneme_plotly_plot.png")

# img <- magick::image_read_pdf(path = "figures/phoneme_plotly_plot.pdf")

# Load the saved image
img <- png::readPNG("figures/phoneme_plotly_plot.png")
img_width <- dim(img)[1] # Image width
img_height <- dim(img)[2] # Image height
res <- dim(img)[1:2]

cairo_pdf(file = "figures/dist-summaries.pdf", width = 12, height = 4, family = "DejaVu Sans")
par(mfrow = c(1, 3), mar = c(5, 6, 4, 1))
GLarE:::summary_correlation_plot(ph_pca,
  cvqlines = 0.9,
  attainment_rate = 0.95,
  tolerance_level = 0.05,
  q = ph_pca$q,
  r = ph_pca$r,
  breaks = ph_pca$breaks,
  method_name = "PCA",
  qd = ph_pca$qd
)



distribution_plot(ph_pca)
title("Dotplot of Distribution: PCA")

par(mar = c(0, 0, 4, 0)) # Adjust margins for alignment
plot(
  1, 1,
  xlim = c(0, 1), ylim = c(0, 1),
  asp = 1, type = "n",
  xaxs = "i", yaxs = "i",
  xaxt = "n", yaxt = "n",
  xlab = "", ylab = "", bty = "n"
)


# Adjust the image position for alignment
graphics::rasterImage(
  img,
  xleft = 0.05 * 1.1, # Slightly shift left for centering
  xright = 0.95 * 1.1, # Scale width proportionally
  ybottom = 0.2 * 1.1 - 0.075, # Shift up slightly for alignment
  ytop = 0.95 * 1.1 - 0.075 # Adjust height proportionally
)

title("Heatmap of Distribution: PCA")
dev.off()
