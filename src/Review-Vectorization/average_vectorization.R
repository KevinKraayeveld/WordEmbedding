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
  embeddings <- model[unlist(token_index),]
  if(length(embeddings) > 1){
    vector <- colMeans(embeddings)
  } else{
    vector <- embeddings
  }
  return(vector)
}

print("get word embeddings and average them")
df[, Review_Vector := lapply(df$Token_index, function(tokens){
  vector_averaging(tokens, model)
})]

end_time <- Sys.time()

# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time of review vectorization:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), 
    "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")

print("remove model from working session")
rm(model)

print("remove unnecessary columns")
df[, Token_index := NULL]
