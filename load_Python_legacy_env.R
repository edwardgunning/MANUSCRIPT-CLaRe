library(reticulate)

project_python <- if (.Platform$OS.type == "windows") {
  file.path(getwd(), ".venv", "Scripts", "python.exe")
} else {
  file.path(getwd(), ".venv", "bin", "python")
}

if (file.exists(project_python)) {
  reticulate::use_python(project_python, required = TRUE)
} else {
  stop("Please install a virtual Python environment in your working directory as described at https://github.com/edwardgunning/MANUSCRIPT-CLaRe")
}

print(reticulate::py_config())
