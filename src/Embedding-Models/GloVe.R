# List of required packages
packages <- c("word2vec", "data.table", "rsparse", "parallel", "quanteda")

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
library(quanteda)

train[, Review := NULL]

# Set the number of threads
num_cores <- detectCores()
options(mc.cores = num_cores)

print("read vocabulary.rds")
if(small_data){
  path_train_vocabulary <- paste0("../data/variables/", preprocessing_method, "_vocabulary_small.rds")
  vocabulary <- readRDS(path_train_vocabulary)
}else{
  path_train_vocabulary <- paste0("../data/variables/", preprocessing_method, "_vocabulary.rds")
  vocabulary <- readRDS(path_train_vocabulary)
}

print("Create tcm")
iter <- itoken(train$Review_Tokens)
vectorizer <- vocab_vectorizer(vocabulary)

start_time <- Sys.time()

tcm <- create_tcm(it = iter, 
                  vectorizer = vectorizer,
                  skip_grams_window = 5L)

rm(vocabulary)

print("Initiate GloVe model")
# Train GloVe embeddings
glove_model <- GloVe$new(rank = 50, # Dimensionality of the vector
                         x_max = 100, # maximum number of co-occurrences to use in the weighting function
                         learning_rate = 0.05, # learning rate for SGD
                         alpha = 0.75, # the alpha in weighting function formula
                         lambda = 0, # regularization parameter
                         shuffle = FALSE)
                  
print("Train GloVe model")
glove_model$fit_transform(x = tcm, # Co-occurence matrix
                          n_iter = 200, # number of SGD iterations
                          convergence_tol = -1) # defines early stopping strategy

rm(tcm)

# Extract trained word embeddings
print("Extract word embeddings")
word_embeddings <- glove_model$components
print("Turn model into matrix and transpose")
# Transpose matrix
model <- t(as.matrix(word_embeddings))

end_time <- Sys.time()

print(paste("Total execution time:", round(end_time - start_time, 2), "seconds"))

print("save model in rds file")
if(small_data){
  saveRDS(model, "../data/models/glove_small.rds")
} else{
  saveRDS(model, "../data/models/glove.rds")
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
