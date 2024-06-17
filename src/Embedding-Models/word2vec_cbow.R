# List of required packages
packages <- c("word2vec", "data.table", "tokenizers", "parallel", "quanteda")

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
library(quanteda)

train[, Review := NULL]
test[, Review := NULL]

start_time <- Sys.time()

set.seed(100)

# Get the amount of CPU cores on this PC.
num_cores <- detectCores()

print("Create word embeddings")
model <- word2vec(x = train$Review_Tokens, 
                  type = "cbow", 
                  dim = 300, # Dimension of the word vectors
                  window = 5L, # Skip length between words
                  iter = 200, # Number of training iterations
                  lr = 0.05, # Learning rate
                  threads = num_cores) # Number of threads to use
# @TODO Fix this to use less memory
model <- as.matrix(model)

end_time <- Sys.time()

print(difftime(end_time, start_time))

print("save model in rds file")
if(small_data){
  saveRDS(model, "../data/models/word2vec_cbow_small.rds")
} else{
  saveRDS(model, "../data/models/word2vec_cbow.rds")
}


# Remove OOV tokens from the test dataset

if(small_data){
  test_vocabulary <- readRDS("../data/Variables/complete_cleaning_test_vocabulary_small.rds")
} else{
  test_vocabulary <- readRDS("../data/Variables/complete_cleaning_test_vocabulary.rds")
}

test_tokens <- tokens(test$Review_Tokens)
oov_tokens <- setdiff(test_vocabulary$term, rownames(model))
filtered_tokens <- tokens_select(test_tokens, oov_tokens, selection = "remove")
test$Review_Tokens <- as.list(filtered_tokens)

print("Remove rows with empty reviews after cleaning")
test <- test[lengths(test$Review_Tokens) > 0, ]

if(small_data){
  path <- paste0("../data/Cleaned-Reviews/", preprocessing_method, "_test_small_no_oov.csv")
} else{
  path <- paste0("../data/Cleaned-Reviews/", preprocessing_method, "_test_no_oov.csv")
}
fwrite(test, path)
