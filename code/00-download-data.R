source("load_Python_legacy_env.R")

# As per reproducibility request:
# - download and checkpoint datasets
# from external URLs

# SINCE THE COPIES OF THE DATASETS ARE NOW UPLOADED TO GITHUB, THIS DOES
# NOT HAVE TO BE RE-RUN EACH TIME

# 1) Phoneme: -------------------------------------------------------------
# Phoenome dataset:
PH_path <- "https://www.math.univ-toulouse.fr/~ferraty/SOFTWARES/NPFDA/npfda-phoneme.dat"
PH <- readr::read_table(file = PH_path, col_names = FALSE)
## -------------------------------------------------------------------------
## NB: Reproducibility Review:
## -------------------------------------------------------------------------
# AS PART OF REPRODUCIBILITY REVIEW:
# Combine with metadata:
phoneme_archive <- list(
  data = PH,
  metadata = list(
    dataset = "phoneme",
    original_source_url = PH_path,
    raw_file_name = "npfda-phoneme.dat",
    saved_at = as.character(Sys.time()),
    script = here::here("code", "08-phoneme-data.R"),
    note = "Local archived copy of the external phoneme data used in the manuscript analyses. Obtained directly from Ferraty's NPFDA website."
  )
)
# Save to disk:
saveRDS(phoneme_archive, here::here("data", "/phoneme_external_data.rds"))
# Checksums:
md5_phoneme <- tools::md5sum(here::here("data", "phoneme_external_data.rds"))
md5_phoneme
writeLines(
  paste(names(md5_phoneme), md5_phoneme),
  here::here("data", "phoneme_external_data_md5.txt")
)
# -------------------------------------------------------------------------
# -------------------------------------------------------------------------

# 2) MNIST ----------------------------------------------------------------
## -------------------------------------------------------------------------
## NB: Reproducibility Review:
## MNIST Dataset.
# -------------------------------------------------------------------------
# AS PART OF REPRODUCIBILITY REVIEW:
# Combine with metadata:
mnist <- keras::dataset_mnist()
mnist_archive <- list(
  data = mnist,
  metadata = list(
    dataset = "mnist",
    keras_package_version = packageVersion("keras"),
    saved_at = as.character(Sys.time()),
    script = here::here("code", "06.1-run-mnist-analysis.R"),
    note = "Local archived copy of the external mnist data used in the manuscript analyses. Obtained directly from keras R package."
  )
)
# Save to disk:
saveRDS(mnist_archive, here::here("data", "mnist_external_data.rds"))
# checksums:
(md5_mnist <- tools::md5sum(here::here("data", "mnist_external_data.rds")))
md5_mnist
writeLines(
  paste(names(md5_mnist), md5_mnist),
  here::here("data", "mnist_external_data_md5.txt")
)


# 3) GaitRec (in Supplement) ----------------------------------------------
# From:
# https://springernature.figshare.com/collections/GaitRec_A_large-scale_ground_reaction_force_dataset_of_healthy_and_impaired_gait/4788012/1

# Citation:
############
# Horsak, Brian; Slijepcevic, Djordje; Raberger, Anna-Maria; Schwab, Caterine; Worisch, Marianne; Zeppelzauer, Matthias (2020).
# GaitRec: A large-scale ground reaction force dataset of healthy and impaired gait. figshare. Collection.
# https://doi.org/10.6084/m9.figshare.c.4788012.v1
############

# Download the following Ground Reaction Forces Data:
# Force (F)
# vertical, anterior-posterior and medio-lateral force components (V, AP, ML)
# Legs: Both Left (left) and Right (right)
# Processing: Smoothed and Normalized (PRO)
# This is a big data set, it might take a while:

# Vertical Force:
GRF_F_V_PRO_left <- readr::read_csv("https://ndownloader.figshare.com/files/22063191")
GRF_F_V_PRO_right <- readr::read_csv("https://ndownloader.figshare.com/files/22063119")

# Medio-lateral Force:
GRF_F_ML_PRO_left <- readr::read_csv("https://ndownloader.figshare.com/files/22063113")
GRF_F_ML_PRO_right <- readr::read_csv("https://ndownloader.figshare.com/files/22063086")

# Anterior-Posterior Force:
GRF_F_AP_PRO_left <- readr::read_csv("https://ndownloader.figshare.com/files/22063185")
GRF_F_AP_PRO_right <- readr::read_csv("https://ndownloader.figshare.com/files/22063101")

# And associated MetaDeta, e.g., session and subject information:
GRF_metadata <- readr::read_csv("https://ndownloader.figshare.com/files/22062960")
# -------------------------------------------------------------------------
# AS PART OF REPRODUCIBILITY REVIEW:
# Combine with metadata:
gaitrec_archive <- list(
  data = list(
    GRF_F_V_PRO_left = GRF_F_V_PRO_left,
    GRF_F_V_PRO_right = GRF_F_V_PRO_right,
    GRF_F_ML_PRO_left = GRF_F_ML_PRO_left,
    GRF_F_ML_PRO_right = GRF_F_ML_PRO_right,
    GRF_F_AP_PRO_left = GRF_F_AP_PRO_left,
    GRF_F_AP_PRO_right = GRF_F_AP_PRO_right,
    GRF_metadata = GRF_metadata
  ),
  metadata = list(
    dataset = "gaitrec",
    original_source_url = c(
      "https://ndownloader.figshare.com/files/22063191",
      "https://ndownloader.figshare.com/files/22063119",
      "https://ndownloader.figshare.com/files/22063113",
      "https://ndownloader.figshare.com/files/22063101",
      "https://ndownloader.figshare.com/files/22062960"
    ),
    saved_at = as.character(Sys.time()),
    script = here::here("code", "additional-multivariate-functional-data.R"),
    note = "Local archived copy of the external gaitrec data used in the appendix analyses. Obtained directly from the gaitrec figshare."
  )
)
# Save to disk:
saveRDS(gaitrec_archive, here::here("data", "gaitrec_external_data.rds"))
# checksums:
(md5_gaitrec <- tools::md5sum(here::here("data", "gaitrec_external_data.rds")))
md5_gaitrec
writeLines(
  paste(names(md5_gaitrec), md5_gaitrec),
  here::here("data", "gaitrec_external_data_md5.txt")
)
# -------------------------------------------------------------------------
# -------------------------------------------------------------------------
