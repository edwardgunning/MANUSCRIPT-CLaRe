library(reticulate)

project_python <- file.path(getwd(), ".venv", "bin", "python")

if (file.exists(project_python)) {
  reticulate::use_python(project_python, required = TRUE)
} else {
  reticulate::use_python("~/.virtualenvs/glare-legacy/bin/python", required = TRUE)
}

print(reticulate::py_config())
