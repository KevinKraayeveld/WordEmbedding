# Install and load necessary packages
packages <- c("reticulate")

for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(reticulate)

# Use the specified Python executable
use_python(python_path)

py_run_string(paste0("small_data = '", small_data, "'"))
py_run_string(paste0("preprocessing_method = '", preprocessing_method, "'"))
source_python("ELMo.py")
