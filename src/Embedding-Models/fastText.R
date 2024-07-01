# List of required packages
packages <- c("data.table", "fastText", "fastTextR", "parallel")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(data.table)
library(fastText)
library(fastTextR)
library(parallel)
test[, Review := NULL]

start_time <- Sys.time()

input_file <- tempfile(fileext = ".txt")

print("Write Review to text file")
writeLines(as.character(train$Review), input_file)

print("Remove Review from train")
train[, Review := NULL]

num_cores <- detectCores()

list_params <- list(command = "cbow",
                   lr = 0.05,
                   dim = 250,
                   input = input_file,
                   output = file.path("../data/fastText/model"),
                   verbose = 2,
                   thread = num_cores)


print("Train fastText model")
s <- Sys.time()


res <- fasttext_interface(list_params,
                          path_output = file.path("../data/fastText/logs_supervise.txt"))

e <- Sys.time()

print(difftime(e, s))

unlink("../data/fastText/logs_supervise.txt")

print("Get train and test vocabulary and write the words to a txt file")
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

words_file <- tempfile(fileext = ".txt")

writeLines(words, words_file)

rm(words)

vectors_file <- tempfile(fileext = ".txt")

list_params <- list(command = "print-word-vectors",
                    model = file.path("../data/fastText/model.bin"))

model <- ft_load("../data/fastText/model.bin")

unlink("../data/fastText/model.vec")
