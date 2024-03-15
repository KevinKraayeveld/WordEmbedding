library(data.table)

# Function to get word vectors for a review. The review is already in tokens format. 
# The model should be in matrix format
get_review_vectors <- function(tokens, model) {
  review_vectors <- lapply(tokens, function(token) {
    if (all(token %in% rownames(model))) {
      # If all words are in vocabulary, get their word vectors
      return(model[token, , drop = FALSE])
    } else {
      # If any word is not in vocabulary, return NA
      return(rep(NA, ncol(model)))
    }
  })
  return(do.call(rbind, review_vectors))  # Combine into a matrix
}

# Add a new column to store the averaged vectors
df[, Review_Vector := lapply(df$Review_Tokens, function(review_tokens) {
  review_vectors <- get_review_vectors(review_tokens, model)
  
  # Filter out rows with NA values
  complete_rows <- complete.cases(review_vectors)
  review_vectors <- review_vectors[complete_rows, , drop = FALSE]
  
  # Calculate the average vector
  if (nrow(review_vectors) > 0) {
    average_vector <- colMeans(review_vectors)
  } else {
    average_vector <- rep(NA, ncol(model))
  }
  return(average_vector)
})]

end_time <- Sys.time()



