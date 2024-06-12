# Install and load necessary packages
packages <- c("reticulate")

for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(reticulate)

train[, Review_Tokens := NULL]
test[, Review_Tokens := NULL]

# Use the specified Python executable
use_python(python_path)

py_run_string(paste0("small_data = '", small_data, "'"))
py_run_string(paste0("preprocessing_method = '", preprocessing_method, "'"))
source_python("Embedding-Models/ELMo.py")

if(small_data){
  train_path <- paste0("../data/", preprocessing_method, "_elmo_train_small.csv")
  test_path  <- paste0("../data/", preprocessing_method, "_elmo_test_small.csv")
}else {
  train_path <- paste0("../data/", preprocessing_method, "_elmo_train.csv")
  test_path  <- paste0("../data/", preprocessing_method, "_elmo_test.csv")
}

train <- fread(train_path)
test <- fread(test_path)