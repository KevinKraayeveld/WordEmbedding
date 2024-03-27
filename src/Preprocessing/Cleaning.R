# List of required packages
packages <- c("data.table", "text2vec", "tm", "tokenizers", "SnowballC", "tidytext", "quanteda")

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

train <- fread("../data/train.csv")
test <- fread("../data/test.csv")

# Change variable names
setnames(train, old = c("V1", "V2", "V3"), new = c("isPositive", "Title", "Review"))
setnames(test, old = c("V1", "V2", "V3"), new = c("isPositive", "Title", "Review"))

# Make positive value 1 and negative value 0
train$isPositive <- train$isPositive - 1
test$isPositive <- test$isPositive - 1

# Transform the isPositive variable to a logical variable
train$isPositive <- as.logical(train$isPositive)
test$isPositive <- as.logical(test$isPositive)

# Merge train and test data.
df <- rbind(train, test)

# Randomly select a number of rows
set.seed(123)
total_rows <- nrow(df)
sample_indices <- sample(total_rows, 1000)
df <- df[sample_indices]

start_time <- Sys.time()

# Remove stop words, punctuation, whitespace, numbers and make everything lower case
print("Start removing punctiation")
df$Review <- removePunctuation(df$Review)
print("Finished removing punctuation, starting to remove numbers")
df$Review <- removeNumbers(df$Review)
print("Removed numbers, now turning everything lowercase")
df$Review <- tolower(df$Review)
print("Now removing whitespace")
df$Review <- stripWhitespace(df$Review)
print("Now removing whitespaces at the first index")
df$Review <- gsub("^\\s+", "", df$Review)

print("Creating tokens")
tokens <- strsplit(df$Review, split = " ", fixed = T)

print("Removing stop words")
data(stop_words)
tokens <- tokens_select(as.tokens(tokens), stop_words$word, selection = "remove")
tokens <- as.list(tokens)

# Stem the tokens
print("Stemming tokens")
tokens <- lapply(tokens, function(token_list) wordStem(token_list, language = "en"))

# Create vocabulary to remove the words that appear less than 5 times in the vocabulary
print("Creating vocabulary")
vocabulary <- create_vocabulary(itoken(tokens), ngram= c(1,1))
print("Pruning vocabulary")
pruned_vocabulary <- prune_vocabulary(vocabulary, term_count_min = 5)

# Write the vocabulary to an RDS file
saveRDS(pruned_vocabulary, file = "../data/Variables/smaller_vocabulary.rds")

words_to_delete <- setdiff(vocabulary$term, pruned_vocabulary$term)

print("Removing tokens that are not in the pruned vocabulary")
remove_tokens <- Sys.time()

tokens <- tokens_select(as.tokens(tokens), words_to_delete, selection = "remove")
tokens <- as.list(tokens)

word_index_dict <- setNames(seq_along(pruned_vocabulary$term), pruned_vocabulary$term)

sorting_order <- names(sorted_word_index_dict)

saveRDS(sorting_order, "../data/Variables/sorting_order.rds")

# Put the tokens list in the data.table in a column called Review_Tokens
df$Review_Tokens <- tokens

df[, Token_index := lapply(df$Review_Tokens, function(tokens){
  unlist(unname(word_index_dict[tokens]))
})]

end_remove_tokens <- Sys.time()
total_execution_time_tokens <- as.numeric(difftime(end_remove_tokens, remove_tokens, units = "secs"))
print(paste("Execution time of removing tokens", total_execution_time_tokens))

print("Removing unnecessary columns")
df <- df[, .(isPositive, Review_Tokens, Token_index)]

end_time <- Sys.time()
# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")

# Write df to a CSV file
fwrite(df, "../data/smaller_tokenized_reviews.csv")
