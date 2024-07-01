# List of required packages
packages <- c("data.table", "fastTextR", "fastText")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(data.table)
library(fastTextR)

if(tolower(embedding_model) %in% c("pretrained_fasttext", "fasttext")){
  get_embeddings <- function(tokens){
    ft_word_vectors(model, tokens)
  }
} else{
  get_embeddings <- function(tokens){
    embeddings <- model[tokens, ]
    return(embeddings)
  }
}
