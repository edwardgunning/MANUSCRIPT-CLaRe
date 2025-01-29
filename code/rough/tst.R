library(GLarE)
eye1 <- as.matrix(glaucoma_data) # simulated copy
eye2 <- as.matrix(read.table(file = "data/Y_outlier_removed.txt")) # data
eye3 <- as.matrix(read.table(file = "data/Y_raw.txt")) # data

eye_1_array <- tensorflow::array_reshape(eye1, c(nrow(eye1), 120, 120))
eye_2_array <- tensorflow::array_reshape(eye2, c(nrow(eye2), 120, 120))
eye_3_array <- tensorflow::array_reshape(eye3, c(nrow(eye3), 120, 120))

par(mfrow = c(1, 3))
tensorflow::set_random_seed(1)
eye_1_dwt <- GLaRe(mat = eye_1_array,
                     learn = "dwt.2d",
                     kf = nrow(eye_1_array),
                     latent_dim_by = 10,
                     latent_dim_to = 1000)
tensorflow::set_random_seed(1)
eye_2_dwt <- GLaRe(mat = eye_2_array,
                   learn = "dwt.2d",
                   kf = nrow(eye_2_array),
                   latent_dim_by = 10,
                   latent_dim_to = 1000)
tensorflow::set_random_seed(1)
eye_3_dwt <- GLaRe(mat = eye_3_array,
                   learn = "dwt.2d",
                   kf = nrow(eye_3_array),
                   latent_dim_by = 10,
                   latent_dim_to = 1000)
