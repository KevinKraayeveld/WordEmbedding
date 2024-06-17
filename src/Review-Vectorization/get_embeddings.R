# List of required packages
packages <- c("data.table", "fastTextR", "fastText")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(data.table)
library(fastTextR)

if(embedding_model == "pretrained_word2vec"){
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
} else if(embedding_model == "pretrained_fastText"){
  get_embeddings <- function(tokens){
    ft_word_vectors(model, tokens)
  }
} else{
  get_embeddings <- function(tokens){
    embeddings <- model[tokens, ]
    return(embeddings)
  }
}
