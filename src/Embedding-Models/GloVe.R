library(data.table)
library(text2vec)
library(rsparse)

start_time <- Sys.time()

tokens <- strsplit(df$Review, split = " ",
                   fixed = T)
iter <- itoken(tokens)
vectorizer <- vocab_vectorizer(vocabulary)
tcm <- create_tcm(it = iter, vectorizer = vectorizer)

word_vectors_dim <- 100  # Size of the embedding vector
window_size <- 10        # Context window size
iterations <- 10         # Number of iterations

# Train GloVe embeddings
glove_model <- GloVe$new(rank = word_vectors_dim,
                         x_max = 100,
                         learning_rate = 0.2)
                  
glove_model$fit_transform(tcm)

# Extract trained word embeddings
word_embeddings <- glove_model$components
model <- t(as.matrix(word_embeddings))

source("Review-Vectorization/Review_vectorization.R")

df <- df[, .(isPositive, Review_Vector)]

end_time <- Sys.time()

# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), 
    "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")

fwrite(df, "../data/Vectorized-Reviews/vectorized_GloVe.csv")
