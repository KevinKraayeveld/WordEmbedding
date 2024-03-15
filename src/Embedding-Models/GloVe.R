library(data.table)
library(text2vec)
library(rsparse)

start_time <- Sys.time()

tokens <- strsplit(df$Review, split = " ",
                   fixed = T)
iter <- itoken(tokens)
vectorizer <- vocab_vectorizer(vocabulary)
tcm <- create_tcm(it = iter, vectorizer = vectorizer)

# Train GloVe embeddings
glove_model <- GloVe$new(rank = 50, # Dimensionality of the vector
                         x_max = 100, # maximum number of co-occurrences to use in the weighting function
                         learning_rate = 0.2, # learning rate for SGD
                         alpha = 0.75, # the alpha in weighting function formula
                         lambda = 0, # regularization parameter
                         shuffle = FALSE)
                  
glove_model$fit_transform(x = tcm, # Co-occurence matrix
                          n_iter = 50, # number of SGD iterations
                          convergence_tol = -1) # defines early stopping strategy

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
