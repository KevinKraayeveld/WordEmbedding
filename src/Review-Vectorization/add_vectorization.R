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
  total_rows <- nrow(df)
  sample_indices <- sample(total_rows, 200000)
  df <- df[sample_indices]
}

start_time <- Sys.time()

add_vectors <- function(tokens){
  source("Review-Vectorization/get_embeddings.R")
  if (inherits(model, "gensim.models.keyedvectors.KeyedVectors")) {
    embeddings <- get_embeddings_gensim_model(tokens)
  } else if(inherits(model, "fasttext")){
    embeddings <- get_embeddings_fasttext_model(tokens)
  } else{
    embeddings <- get_embeddings_matrix_model(tokens)
  }
  if(is.null(dim(embeddings)[1])){
    vector <- embeddings
  } else{
    vector <- colSums(embeddings)
  }
  return(vector)
}

df[, Review_Vector := lapply(df$Review_Tokens, function(tokens){
  add_vectors(tokens)
})]
test[, Review_Vector := lapply(test$Review_Tokens, function(tokens){
  add_vectors(tokens)
})]


# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time of review vectorization:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), 
    "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")

print("remove model from working session")
#rm(model)

print("remove unnecessary columns")
df[, c("Review_Tokens", "Review") := NULL]
test[, c("Review_Tokens", "Review") := NULL]