# List of required packages
packages <- c("data.table", "fastTextR")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(data.table)
library(fastTextR)

if(!small_data){
  total_rows <- nrow(train)
  sample_indices <- sample(total_rows, 200000)
  train <- train[sample_indices]
}

start_time <- Sys.time()

source("Review-Vectorization/get_embeddings.R")

vector_stacking <- function(tokens){
  embeddings <- get_embeddings(tokens)
  return(embeddings)
}

print("Stack embeddings")
train[, Review_Vector := lapply(train$Review_Tokens, function(tokens){
  vector_stacking(tokens)
})]
test[, Review_Vector := lapply(test$Review_Tokens, function(tokens){
  vector_stacking(tokens)
})]

pad_vector <- function(token_vector){
  max_length_train <- max(lengths(train$Review_Vector))
  max_length_test <- max(lengths(test$Review_Vector))
  max_length <- max(max_length_test, max_length_train)
  zeros_to_add <- max_length - length(token_vector)
  padded_vector <- c(token_vector, rep(0, zeros_to_add))
  return(padded_vector)
}

print("add zeros")
train[, Review_Vector := lapply(Review_Vector, pad_vector)]
test[, Review_Vector := lapply(Review_Vector, pad_vector)]

end_time <- Sys.time()

print(difftime(end_time, start_time))

print("remove unnecessary columns")
train[, c("Review_Tokens", "Review") := NULL]
test[, c("Review_Tokens", "Review") := NULL]