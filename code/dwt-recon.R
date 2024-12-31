library(GLarE)
library(data.table)
library(ggplot2)
source("code/theme_gunning.R")
theme_gunning()

DTI <- refund::DTI$cca
DTI <- na.omit(DTI)

learn_dwt <- GLarE:::learn_dwt(Y = DTI)
k_vec <- c(20, 40, 60, 80, 93)
Xhat_list <- vector("list", length = length(k_vec))
names(Xhat_list) <- k_vec
for(k in seq_along(k_vec)) {
  print(paste0("k = ", k_vec[k]))
  Xhat_list[[k]] <- learn_dwt$Decode(Ystar = learn_dwt$Encode(DTI, k_vec[k]))
}

recon_dt <- purrr::map_dfr(Xhat_list, function(X) {
  dt <- data.table(id = 1:nrow(X), X)
  dt_lng <- melt.data.table(data = dt, id.vars = "id", variable.factor = FALSE)
}, .id = "k")
recon_dt[, variable := as.numeric(stringr::str_remove(variable, "V"))]
recon_dt[, k := as.numeric(k)]
recon_dt[, k := paste0("K = ", k)]
DTI_lng <- melt.data.table(data.table(id = 1:nrow(DTI), DTI),
                           id.vars = "id",
                           variable.factor = FALSE)
DTI_lng[, variable := as.numeric(stringr::str_remove(variable, "cca_"))]

DTI_lng$k <- "Original Data"


plot_dt <- rbind(recon_dt, DTI_lng)
plot_dt

set.seed(1)
cols <- rainbow(n = nrow(DTI))
cols <- sample(cols)
ggplot(data = plot_dt) +
  facet_wrap(~ k, scales = "free_x") +
  aes(x = variable, y = value, group = id, colour = factor(id)) +
  geom_line(alpha = 0.6) +
  theme(legend.position = "none") +
  scale_color_manual(values = cols) +
  labs(x = expression(t), y = expression(X(t)))


ggsave(filename = "figures/DTI-recon.pdf", device = "pdf", width = 10 * 0.65, height = 10 * (2/3) * 0.65)



