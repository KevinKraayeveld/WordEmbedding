# List of required packages
packages <- c("data.table", "reticulate")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(reticulate)
library(data.table)

use_python(python_path)

transformer <- reticulate::import('transformers')
tf <- reticulate::import('tensorflow')
builtins <- import_builtins() #built in python methods

model <- transformer$TFAutoModel$from_pretrained("bert-base-uncased")
tokenizer <- transformer$AutoTokenizer$from_pretrained('bert-base-uncased')

average_review <- function(review){
  # Tokenize review the BERT way
  tokenized <- tokenizer$encode_plus(review, 
                                     max_length = 20L, 
                                     pad_to_max_length = TRUE, 
                                     return_tensors = "tf")
  
  # Get input ids of the tokens
  input_ids <- tokenized$input_ids
  
  # Get embedding from model
  output <- model$predict(input_ids)
  
  # Get the embedding for each token and average them
  last_hidden_state <- output$last_hidden_state
  average_hidden_state <- tf$reduce_mean(last_hidden_state, axis = 2L)
  
  # Convert embedding to vector
  embedding_vector <- as.vector(average_hidden_state$numpy())
  return(embedding_vector)
}

#df[, Review_Vector := lapply(df$Review, function(review){
#  average_review(review)
#})]

pooler_review <- function(review){
  # Tokenize review the BERT way
  tokenized <- tokenizer$encode_plus(review, 
                                     max_length = 20L, 
                                     pad_to_max_length = T, 
                                     return_tensors = "tf")
  
  # Get input ids of the tokens
  input_ids <- tokenized$input_ids
  
  # Get embedding from model
  output <- model$predict(input_ids)
  
  pooler <- output$pooler_output
  return(as.vector(pooler))
}

df[, Review_Vector := lapply(df$Review, function(review){
  pooler_review(review)
})]
test[, Review_Vector := lapply(test$Review, function(review){
  pooler_review(review)
})]

df[, c("Review_Tokens", "Review") := NULL]
test[, c("Review_Tokens", "Review") := NULL]


