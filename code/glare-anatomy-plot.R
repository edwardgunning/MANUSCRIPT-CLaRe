library(GLarE)

set.seed(1)

eye <- as.matrix(glaucoma_data)

eye_pca <- GLaRe(mat = eye, learn = "pca", latent_dim_by = 10)

cairo_pdf(file = "figures/glare-anatomy-plot.pdf", width = 7, height = 7, family="DejaVu Sans")
par(mfrow = c(1,1), mar=c(5,6,4,1), cex = 1.25)
GLarE:::summary_correlation_plot(out_basisel = eye_pca,
                                 cvqlines = 0.9,
                                 attainment_rate = 0.95,
                                 tolerance_level = 0.05,
                                 r = eye_pca$r, q = eye_pca$q,
                                 qd = eye_pca$qd,
                                 breaks = eye_pca$breaks,
                                 method_name = "Demo of PCA on Glaucoma Data")
dev.off()

set.seed(1)
cairo_pdf(file = "figures/additional-plots-01.pdf", width = 12, height = 6, family="DejaVu Sans")
par(mfrow = c(1, 2))
GLarE::distribution_plot(GLaRe_output = eye_pca)
title("(a) distribution_plot()")
GLarE::plot_train_validation_ratio(GLaRe_output = eye_pca)
title("(b) plot_train_validation_ratio()")
dev.off()

GLarE::plot_eye_reconstruction(GLaRe_output = eye_pca, y = eye[1,])
ggplot2::ggsave(filename = "figures/eye-reconstruction.pdf",
                device = "pdf",
                width = 8.25,
                height = 6.74,
                dpi = 400)

# heatmap + save manually using browser:
eye_pca$heatmap
