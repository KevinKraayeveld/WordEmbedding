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

get_embeddings <- function(tokens) {
  # Initialize an empty matrix to store embeddings
  embedding_size <- model$vector_size
  embeddings_matrix <- matrix(NA, nrow = length(tokens), ncol = embedding_size)
  
  # Fill the matrix with embeddings
  for (i in seq_along(tokens)) {
    token <- tokens[[i]]
    embedding <- tryCatch({
      model$get_vector(token)
    }, error = function(e) {
      rep(NA, embedding_size)
    })
    embeddings_matrix[i, ] <- embedding
  }
  
  # Assign row names
  rownames(embeddings_matrix) <- tokens
  
  return(embeddings_matrix)
}

add_vectors <- function(tokens){
  if (inherits(model, "gensim.models.keyedvectors.KeyedVectors")) {
    embeddings <- get_embeddings(tokens)
  } else{
    embeddings <- model[unlist(tokens),]
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

# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time of review vectorization:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), 
    "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")

print("remove model from working session")
#rm(model)

print("remove unnecessary columns")
df[, Token_index := NULL]