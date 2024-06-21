packages <- c("reticulate", "quanteda", "data.table")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(reticulate)
library(quanteda)
library(data.table)

train[, Review := NULL]
test[, Review := NULL]

use_python(python_path)

# Install gensim on python
gensim <- import("gensim")

model_path <- "../pretrained_models/GoogleNews-vectors-negative300.bin"
gensim_model <- gensim$models$KeyedVectors$load_word2vec_format(model_path, binary = TRUE)

if(small_data){
  words_path <- paste0("../data/variables/", preprocessing_method, "_words_small.rds")
  test_vocabulary_path <- paste0("../data/variables/", preprocessing_method, "_test_vocabulary_small.rds")
}else{
  words_path <- paste0("../data/variables/", preprocessing_method, "_words.rds")
  test_vocabulary_path <- paste0("../data/variables/", preprocessing_method, "_test_vocabulary.rds")
}
train_vocabulary_terms <- readRDS(words_path)
test_vocabulary <- readRDS(test_vocabulary_path)

rm(test_vocabulary_path, words_path)

words <- union(train_vocabulary_terms, test_vocabulary$term)

rm(train_vocabulary_terms, test_vocabulary)

embeddings_list <- list()

for (word in words){
  tryCatch({
    embedding <- gensim_model$get_vector(word)
    embeddings_list[[word]] <- embedding
  }, error = function(e){
    
  })
}

model <- do.call(rbind, embeddings_list)

rm(embeddings_list)

if(small_data){
  saveRDS(model, "../data/models/pretrained_word2vec_small.rds")
} else{
  saveRDS(model, "../data/models/pretrained_word2vec.rds")
}

if(small_data){
  test_vocabulary <- readRDS("../data/Variables/complete_cleaning_test_vocabulary_small.rds")
  train_vocabulary <- readRDS("../data/Variables/complete_cleaning_vocabulary_small.rds")
} else{
  test_vocabulary <- readRDS("../data/Variables/complete_cleaning_test_vocabulary.rds")
  train_vocabulary <- readRDS("../data/Variables/complete_cleaning_vocabulary.rds")
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

train_tokens <- tokens(train$Review_Tokens)
oov_tokens <- setdiff(train_vocabulary$term, rownames(model))
filtered_tokens <- tokens_select(train_tokens, oov_tokens, selection = "remove")
train$Review_Tokens <- as.list(filtered_tokens)

print("Remove rows with empty reviews after cleaning")
train <- train[lengths(train$Review_Tokens) > 0, ]

if(small_data){
  path <- paste0("../data/Cleaned-Reviews/", preprocessing_method, "_train_small_no_oov.csv")
} else{
  path <- paste0("../data/Cleaned-Reviews/", preprocessing_method, "_train_no_oov.csv")
}
fwrite(train, path)
