library(data.table)
library(text2vec)
library(rsparse)

iter <- itoken(df$Review_Tokens)
vectorizer <- vocab_vectorizer(vocabulary)
tcm <- create_tcm(iter, vectorizer)

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

source("Review-Vectorization/Review_vectorization.R")
