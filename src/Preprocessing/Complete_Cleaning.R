# List of required packages
packages <- c("data.table", "text2vec", "tm", "tokenizers", "SnowballC", "tidytext", "quanteda", "stringi")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(data.table)
library(text2vec)
library(tm)
library(tokenizers)
library(SnowballC)
library(tidytext)
library(quanteda)
library(stringi)

train <- fread("../data/train.csv")
test <- fread("../data/test.csv")

# Change variable names
setnames(train, old = c("V1", "V2", "V3"), new = c("isPositive", "Title", "Review"))
setnames(test, old = c("V1", "V2", "V3"), new = c("isPositive", "Title", "Review"))

# Make positive value 1 and negative value 0
train$isPositive <- train$isPositive - 1
test$isPositive <- test$isPositive - 1

train[, Title := NULL]
test[, Title := NULL]

# Transform the isPositive variable to a logical variable
train$isPositive <- as.logical(train$isPositive)
test$isPositive <- as.logical(test$isPositive)

df <- train

rm(list = c("train"))

if(small_data){
  # Randomly select a number of rows
  set.seed(123)
  total_rows <- nrow(df)
  sample_indices <- sample(total_rows, 80000)
  df <- df[sample_indices]
  total_rows <- nrow(test)
  sample_indices <- sample(total_rows, 20000)
  test <- test[sample_indices]
}

start_time <- Sys.time()

# Remove stop words, punctuation, whitespace, numbers and make everything lower case
print("Remove punctuation")
df$Review <- removePunctuation(df$Review, preserve_intra_word_contractions = TRUE)
test$Review <- removePunctuation(test$Review, preserve_intra_word_contractions = TRUE)
print("Remove numbers")
df$Review <- removeNumbers(df$Review)
test$Review <- removeNumbers(test$Review)
print("Remove whitespace")
df$Review <- stripWhitespace(df$Review)
test$Review <- stripWhitespace(test$Review)
print("Remove whitespaces at the first index")
df$Review <- gsub("^\\s+", "", df$Review)
test$Review <- gsub("^\\s+", "", test$Review)
print("Remove punctuation again")
df$Review <- removePunctuation(df$Review, preserve_intra_word_contractions = TRUE)
test$Review <- removePunctuation(test$Review, preserve_intra_word_contractions = TRUE)
print("Remove accents and turn to lowercase")
df$Review <- char_tolower(stri_trans_general(df$Review, "Latin-ASCII"))
test$Review <- char_tolower(stri_trans_general(test$Review, "Latin-ASCII"))
print("Remove punctuation again")
df$Review <- removePunctuation(df$Review, preserve_intra_word_contractions = TRUE)
test$Review <- removePunctuation(test$Review, preserve_intra_word_contractions = TRUE)

print("Create tokens")
tokens <- strsplit(df$Review, split = " ", fixed = T)
test_tokens <- strsplit(test$Review, split = " ", fixed = T)

print("Remove stop words")
data(stop_words)
tokens <- tokens_select(as.tokens(tokens), stop_words$word, selection = "remove")
test_tokens <- tokens_select(as.tokens(test_tokens), stop_words$word, selection = "remove")
tokens <- as.list(tokens)
test_tokens <- as.list(test_tokens)

# Stem the tokens
print("Stem tokens")
tokens <- lapply(tokens, function(token_list) wordStem(token_list, language = "en"))
test_tokens <- lapply(test_tokens, function(token_list) wordStem(token_list, language = "en"))

# Create vocabulary to remove the words that appear less than 5 times in the vocabulary
print("Create vocabulary")
vocabulary <- create_vocabulary(itoken(tokens), ngram= c(1,1))
test_vocabulary <- create_vocabulary(itoken(test_tokens), ngram= c(1,1))
print("Prune vocabulary")
pruned_vocabulary <- prune_vocabulary(vocabulary, term_count_min = 5)

# Write the vocabulary to an RDS file
print("Save vocabulary in rds file")
if(small_data){
  saveRDS(pruned_vocabulary, file = "../data/Variables/complete_cleaning_vocabulary_small.rds")
  saveRDS(test_vocabulary, file = "../data/variables/complete_cleaning_test_vocabulary_small.rds")
} else{
  saveRDS(pruned_vocabulary, file = "../data/Variables/complete_cleaning_vocabulary.rds")
  saveRDS(test_vocabulary, file = "../data/variables/complete_cleaning_test_vocabulary.rds")
}

words_to_delete <- setdiff(vocabulary$term, pruned_vocabulary$term)

print("Remove vocabulary from working directory")
rm(list = c("vocabulary", "pruned_vocabulary"))

print("Remove tokens that are not in the pruned vocabulary")
remove_tokens <- Sys.time()

tokens <- tokens_select(as.tokens(tokens), words_to_delete, selection = "remove")
tokens <- as.list(tokens)
test_tokens <- as.list(test_tokens)

rm(words_to_delete)

print("Save words")
words <- unique(unlist(tokens))

print("Save words")
if(small_data){
  saveRDS(words, "../data/Variables/complete_cleaning_words_small.rds")
} else{
  saveRDS(words, "../data/Variables/complete_cleaning_words.rds")
}

rm(words)

print("Create Review_Tokens column")
df$Review_Tokens <- tokens
test$Review_Tokens <- test_tokens

print("Remove tokens variable from working memory")
rm(list = c("tokens", "test_tokens"))

print("Remove rows with empty reviews after cleaning")
df <- df[lengths(df$Review_Tokens) > 0, ]

df$Review <- lapply(df$Review_Tokens, function(tokens) {
  paste(tokens, collapse = " ")
})
test$Review <- lapply(test$Review_Tokens, function(tokens) {
  paste(tokens, collapse = " ")
})

end_time <- Sys.time()
# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")

# Write df to a CSV file
if(small_data){
  fwrite(df, "../data/complete_cleaning_train_small.csv")
  fwrite(test, "../data/complete_cleaning_test_small.csv")
} else{
  fwrite(df, "../data/complete_cleaning_train.csv")
  fwrite(test, "../data/complete_cleaning_test.csv")
}
