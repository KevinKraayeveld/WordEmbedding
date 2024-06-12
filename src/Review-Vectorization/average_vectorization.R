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

vector_averaging <- function(tokens){
  embeddings <- get_embeddings(tokens)
  if(is.null(dim(embeddings)[1])){
    vector <- embeddings
  } else{
    vector <- colMeans(embeddings, na.rm = TRUE)
  }
  return(vector)
}

print("get train word embeddings and average them")
train[, Review_Vector := lapply(train$Review_Tokens, function(tokens){
  vector_averaging(tokens)
})]
print("get test word embeddings and average them")
test[, Review_Vector := lapply(test$Review_Tokens, function(tokens){
  vector_averaging(tokens)
})]

end_time <- Sys.time()

print(paste("Total execution time:", round(end_time - start_time, 2), "seconds"))

print("remove model from working session")
#rm(model)

train[, c("Review_Tokens", "Review") := NULL]
test[, c("Review_Tokens", "Review") := NULL]
