library(GLarE)
data("glaucoma_data", package = "GLarE")
data("glaucoma_data", package = "GLarE")

eye <- as.matrix(glaucoma_data)

eye_pca <- GLaRe(mat = eye, learn = "pca", latent_dim_by = 10, latent_dim_to = 20)

data("glaucoma_data", package = "GLarE")
