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

add_vectors <- function(tokens){
  embeddings <- get_embeddings(tokens)
  if(is.null(dim(embeddings)[1])){
    vector <- embeddings
  } else{
    vector <- colSums(embeddings)
  }
  return(vector)
}

end_time <- Sys.time()

print("get train embeddings and sum")
train[, Review_Vector := lapply(train$Review_Tokens, function(tokens){
  add_vectors(tokens)
})]
print("get test embeddings and sum")
test[, Review_Vector := lapply(test$Review_Tokens, function(tokens){
  add_vectors(tokens)
})]

print(difftime(end_time, start_time))

print("remove unnecessary columns")
train[, c("Review_Tokens", "Review") := NULL]
test[, c("Review_Tokens", "Review") := NULL]