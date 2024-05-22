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

get_embeddings_gensim_model <- function(tokens) {
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

get_embeddings_matrix_model <- function(tokens){
  embeddings_list <- lapply(tokens, function(token){
    tryCatch({
      embedding <- model[token, ]
      return(embedding)
    }, error = function(e) {
      return(rep(NA, ncol(model)))
    })
  })
  embeddings <- do.call(rbind, embeddings_list)
  return(embeddings)
}

vector_averaging <- function(tokens){
  if (inherits(model, "gensim.models.keyedvectors.KeyedVectors")) {
    embeddings <- get_embeddings_gensim_model(tokens)
  } else{
    embeddings <- get_embeddings_matrix_model(tokens)
  }
  if(is.null(dim(embeddings)[1])){
    vector <- embeddings
  } else{
    vector <- colMeans(embeddings, na.rm = TRUE)
  }
  return(vector)
}

print("get word embeddings and average them")
df[, Review_Vector := lapply(df$Review_Tokens, function(tokens){
  vector_averaging(tokens)
})]

test[, Review_Vector := lapply(test$Review_Tokens, function(tokens){
  vector_averaging(tokens)
})]

end_time <- Sys.time()

# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time of review vectorization:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), 
    "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")

print("remove model from working session")
#rm(model)
