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

add_vectors <- function(tokens){
  embeddings <- model[unlist(tokens),]
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

# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time of review vectorization:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), 
    "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")

print("remove model from working session")
#rm(model)

print("remove unnecessary columns")
df[, Token_index := NULL]