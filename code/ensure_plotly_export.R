ensure_plotly_export <- function() {
  if (!reticulate::py_module_available("plotly")) {
    reticulate::py_install("plotly", pip = TRUE)
  }

  if (!reticulate::py_module_available("kaleido")) {
    reticulate::py_install("kaleido", pip = TRUE)
  }

  reticulate::py_run_string("
import kaleido
try:
    kaleido.get_chrome_sync()
except Exception as e:
    print(f'Kaleido Chrome setup skipped/failed: {e}')
")
}
