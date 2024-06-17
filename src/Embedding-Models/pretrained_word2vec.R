library(reticulate)

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

