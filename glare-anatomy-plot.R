library(GLarE)

set.seed(1)

eye <- as.matrix(glaucoma_data)

eye_pca <- GLaRe(mat = eye, learn = "pca", latent_dim_by = 10)

cairo_pdf(file = "figures/glare-anatomy-plot.pdf", width = 7, height = 7, family="DejaVu Sans")
par(mfrow = c(1,1), mar=c(5,6,4,1))
GLarE:::summary_correlation_plot(out_basisel = eye_pca,
                                 cvqlines = 0.9,
                                 cutoff_criterion = 0.95,
                                 tolerance_level = 0.05,
                                 r = eye_pca$r, q = eye_pca$q,
                                 qc = eye_pca$qc,
                                 breaks = eye_pca$breaks,
                                 method_name = "Demo of PCA on Glaucoma Data")
dev.off()
