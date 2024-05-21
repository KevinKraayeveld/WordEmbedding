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

vector_stacking <- function(tokens){
  if (inherits(model, "gensim.models.keyedvectors.KeyedVectors")) {
    embeddings <- get_embeddings(tokens)
  } else{
    embeddings <- model[unlist(tokens),]
  }
  return(embeddings)
}

print("Stack embeddings")
df[, Review_Vector := lapply(df$Review_Tokens, function(tokens){
  vector_stacking(tokens)
})]

pad_vector <- function(token_vector){
  max_length <- max(lengths(df$Review_Vector))
  zeros_to_add <- max_length - length(token_vector)
  padded_vector <- c(token_vector, rep(0, zeros_to_add))
  return(padded_vector)
}

print("add zeros")
df[, Review_Vector := lapply(Review_Vector, pad_vector)]

end_time <- Sys.time()

# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time of review vectorization:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), 
    "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")

print("remove model from working session")
#rm(model)

print("remove unnecessary columns")
df[, Token_index := NULL]
    