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

source("Review-Vectorization/get_embeddings.R")

vector_stacking <- function(tokens){
  embeddings <- get_embeddings(tokens)
  return(embeddings)
}

print("Stack embeddings")
df[, Review_Vector := lapply(df$Review_Tokens, function(tokens){
  vector_stacking(tokens)
})]
test[, Review_Vector := lapply(test$Review_Tokens, function(tokens){
  vector_stacking(tokens)
})]

pad_vector <- function(token_vector){
  max_length_df <- max(lengths(df$Review_Vector))
  max_length_test <- max(lengths(test$Review_Vector))
  max_length <- max(max_length_test, max_length_df)
  zeros_to_add <- max_length - length(token_vector)
  padded_vector <- c(token_vector, rep(0, zeros_to_add))
  return(padded_vector)
}

print("add zeros")
df[, Review_Vector := lapply(Review_Vector, pad_vector)]
test[, Review_Vector := lapply(Review_Vector, pad_vector)]

end_time <- Sys.time()

# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time of review vectorization:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), 
    "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")

print("remove model from working session")
#rm(model)

print("remove unnecessary columns")
df[, c("Review_Tokens", "Review") := NULL]
test[, c("Review_Tokens", "Review") := NULL]s
    