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
    })
  })
  embeddings <- do.call(rbind, embeddings_list)
  return(embeddings)
}

get_embeddings_fasttext_model <- function(tokens){
  ft_word_vectors(model, tokens)
}