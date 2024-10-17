library(GLarE)
library(data.table)
library(ggplot2)
library(ggh4x)
DTI <- refund::DTI$cca
DTI <- na.omit(DTI)
source("code/theme_gunning.R")
theme_gunning()

DTI_padded <- GLarE:::prepare_pad_dwt(DTI)

DTI_lng <- melt.data.table(data.table(id = 1:nrow(DTI), DTI),
                           id.vars = "id",
                           variable.factor = FALSE)
colnames(DTI_padded$Ypad) <- paste0("cca_", 1:DTI_padded$ppad)
DTI_padded_lng <- melt.data.table(data.table(id = 1:nrow(DTI_padded$Ypad), DTI_padded$Ypad),
                           id.vars = "id",
                           variable.factor = FALSE)

DTI_lng[, variable := as.numeric(stringr::str_remove(variable, "cca_"))]
DTI_padded_lng[, variable := as.numeric(stringr::str_remove(variable, "cca_"))]

DTI_lng$pad <- "Original Data"
DTI_padded_lng$pad <- "Padded"
plot_DTI_dt <- rbind(DTI_lng, DTI_padded_lng)

set.seed(1)
cols <- rainbow(n = nrow(DTI))
cols <- sample(cols)

ggplot(data = plot_DTI_dt) +
  facet_wrap(~ pad, scales = "free_x") +
  aes(x = variable, y = value, group = id, colour = factor(id)) +
  geom_line(alpha = 0.6) +
  theme(legend.position = "none") +
  scale_color_manual(values = cols) +
  labs(x = expression(t), y = expression(X(t))) +
  facetted_pos_scales(
    x = list(
      scale_x_continuous(breaks = c(1, 47, 93)),
      scale_x_continuous(breaks = c(1, 64, 128),
                         labels = c(expression(1 ~ "=" ~ 2^0), expression(64 ~ "=" ~ 2^6), expression(128 ~ "=" ~ 2^7)))
    ))

ggsave(filename = "figures/DTI-padded.pdf", device = "pdf", width = 10 * 0.65, height = 10 * 0.325)

