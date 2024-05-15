# List of required packages
packages <- c("word2vec", "data.table", "tokenizers", "parallel")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(word2vec)
library(data.table)
library(tokenizers)
library(parallel)

start_time <- Sys.time()

set.seed(100)

# Get the amount of CPU cores on this PC.
num_cores <- detectCores()

model <- word2vec(x = df$Review_Tokens, 
                  type = "skip-gram", 
                  dim = 50, # Dimension of the word vectors
                  window = 5L, # Skip length between words
                  iter = 50, # Number of training iterations
                  lr = 0.05, # Learning rate
                  threads = num_cores) # Number of threads to use
# @TODO Fix this to use less memory
model <- as.matrix(model)

end_time <- Sys.time()

# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), 
    "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")

print("read sorting_order.rds")
if(small_data){
  sorting_order <- readRDS("../data/variables/sorting_order_small.rds")
}else{
  sorting_order <- readRDS("../data/variables/sorting_order.rds")
}

print("sort model")
# @TODO Fix this to use less memory
model <- model[sorting_order, , drop = FALSE]

print("remove sorting_order from working session")
rm(sorting_order)

print("save model in rds file")
saveRDS(model, "../data/models/word2vec_skipgram.rds")

print("remove unnecessary columns")
df[, Review_Tokens := NULL]

