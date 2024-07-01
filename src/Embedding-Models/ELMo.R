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
py_run_string(paste0("path = '", getwd(), "'"))
source_python("Embedding-Models/ELMo.py")

if(small_data){
  train_path <- paste0("../data/Vectorized-Reviews/", preprocessing_method, "_elmo_train_small.csv")
  test_path  <- paste0("../data/Vectorized-Reviews/", preprocessing_method, "_elmo_test_small.csv")
}else {
  train_path <- paste0("../data/Vectorized-Reviews/", preprocessing_method, "_elmo_train.csv")
  test_path  <- paste0("../data/Vectorized-Reviews/", preprocessing_method, "_elmo_test.csv")
}
train <- fread(train_path)
test <- fread(test_path)

convert_to_vector <- function(vector_string) {
  # Remove brackets
  vector_string <- gsub("\\[|\\]", "", vector_string)
  # Split by comma and convert to numeric
  as.numeric(unlist(strsplit(vector_string, ",")))
}

train[, Review_Vector := lapply(Review_Vector, convert_to_vector)]
test[, Review_Vector := lapply(Review_Vector, convert_to_vector)]
