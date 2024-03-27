# List of required packages
packages <- c("data.table")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(data.table)

start_time <- Sys.time()

vector_averaging <- function(token_index, model){
  print("getting embeddings")
  start_embeddings <- Sys.time()
  embeddings <- model[unlist(token_index),]
  end_embeddings <- Sys.time()
  print(difftime(end_embeddings, start_embeddings))
  print("averaging vectors")
  start_averaging <- Sys.time()
  vector <- colMeans(embeddings)
  end_averaging <- Sys.time()
  print(difftime(end_averaging, start_averaging))
  return(vector)
}

df[, Review_Vector := lapply(df$Token_index, function(tokens){
  vector_averaging(tokens, model)
})]

end_time <- Sys.time()

# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time of review vectorization:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), 
    "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")