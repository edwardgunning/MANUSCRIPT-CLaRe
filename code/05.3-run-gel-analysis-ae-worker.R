library(GLarE)
tensorflow::set_random_seed(1)
k_seq <-seq(1, 300, by = 10)
# Read command-line arguments
args <- commandArgs(trailingOnly = TRUE)
# Get the iteration index from the arguments
iteration <- as.numeric(args[1])
k <- k_seq[iteration]

# Print the iteration number
print(paste("This is iteration", iteration))

load("data/proteomic_gels.RData")
gels.data <- aperm(gels.data, perm = c(3, 2, 1))
gels.data_vec <- keras::array_reshape(x = gels.data, dim = c(53, 861 * 646))

time <- system.time({result <- flf_basissel(mat = gels.data_vec,
             latent_dim_from = k,
             latent_dim_by = 1,
             latent_dim_to = k,
             learn = "ae",
             ae_args = list(link_fun = "linear"),
             kf = 5)})

saveRDS(object = list(glare = result, time = time), file = paste0("data/gels-ae-result-", k, ".rds"))
