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

df[, Review_Tokens := NULL]

start_time <- Sys.time()

input_file <- tempfile(fileext = ".txt")

print("Write Review to text file")
writeLines(df$Review, input_file)

print("Remove Review from df")
df[, Review := NULL]

num_cores <- detectCores()

list_params <- list(command = "cbow",
                   lr = 0.1,
                   dim = 50,
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

print("Get words and write it to a txt file")
if(small_data){
  words_path <- paste0("../data/variables/", preprocessing_method, "_words_small.rds")
}else{
  words_path <- paste0("../data/variables/", preprocessing_method, "_words.rds")
}
words <- readRDS(words_path)

words_file <- tempfile(fileext = ".txt")

writeLines(words, words_file)

rm(words)

vectors_file <- tempfile(fileext = ".txt")

list_params <- list(command = "print-word-vectors",
                    model = file.path("../data/fastText/model.bin"))

print("Get word embeddings and write to txt file")
res <- fasttext_interface(list_params,
                          path_input = words_file,
                          path_output = vectors_file)

unlink("../data/fastText/model.bin")
unlink("../data/fastText/model.vec")

lines <- readLines(vectors_file)

print("Get word embeddings from txt file and put them in a list")
# Remove unnecessary characters and split the input into word and numbers
data <- lapply(lines, function(x) {
  parts <- strsplit(gsub("\\[\\d+\\] \"|\"", "", x), "\\s+")
  list(word = parts[[1]][1], numbers = as.numeric(parts[[1]][-1]))
})

rm(lines)

print("Transform list to named matrix")
model <- do.call(rbind, lapply(data, function(x) {
  row.names <- x$word
  numbers <- x$numbers
  c(numbers)
}))

rownames(model) <- sapply(data, function(x) x$word)

rm(data)

end_time <- Sys.time()

# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), 
    "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")

df[, Review := NULL]

print("save model in rds file")
saveRDS(model, "../data/models/fastText.rds")
