# List of required packages
packages <- c("word2vec", "data.table", "rsparse", "parallel")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}


library(data.table)
library(text2vec)
library(rsparse)
library(parallel)

start_time <- Sys.time()

iter <- itoken(df$Review_Tokens)
vectorizer <- vocab_vectorizer(vocabulary)
tcm <- create_tcm(it = iter, vectorizer = vectorizer)

# Train GloVe embeddings
glove_model <- GloVe$new(rank = 50, # Dimensionality of the vector
                         x_max = 100, # maximum number of co-occurrences to use in the weighting function
                         learning_rate = 0.2, # learning rate for SGD
                         alpha = 0.75, # the alpha in weighting function formula
                         lambda = 0, # regularization parameter
                         shuffle = FALSE)

# Set the number of threads
num_cores <- detectCores()
options(mc.cores = num_cores)
                  
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
