library(word2vec)
library(data.table)
library(tokenizers)

start_time <- Sys.time()

set.seed(100)

model <- word2vec(x = df$Review_Tokens, type = "skip-gram", dim = 50, iter = 50)
model <- as.matrix(model)

source("Review-Vectorization/Review_vectorization.R")

df <- df[, .(isPositive, Review_Vector)]

end_time <- Sys.time()

# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), 
    "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")

fwrite(df, "../data/Vectorized-Reviews/vectorized_word2vec_skipgram.csv")
