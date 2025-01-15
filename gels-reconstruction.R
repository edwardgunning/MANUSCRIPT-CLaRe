gel_results <- readRDS("data/gels-results.rds")

gel_results <- gel_results$glare

library(GLarE)

load("data/proteomic_gels.RData")
gels.data <- aperm(gels.data, perm = c(3, 2, 1))
gels.data_vec <- keras::array_reshape(x = gels.data, dim = c(53, 861 * 646))

GLarE:::plot_gel_reconstruction(gel_results$dwt, gels.data_vec[2,])

ystar <- gel_results$dwt$Encode(Y = gels.data_vec)
yhat <- gel_results$dwt$Decode(Ystar = ystar)




sapply(1:nrow(ystar),
      function(i) {GLarE:::get_one_minus_squared_correlation(observed = yhat[i, ], gels.data_vec[i, ])})

