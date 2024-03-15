library(data.table)
library(text2vec)
library(tm)
library(tokenizers)

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

# Temporary dataset to test code on
df <- head(df, 1000)

start_time <- Sys.time()

# Remove stop words, punctuation, whitespace, numbers and make everything lower case
df$Review <- removePunctuation(df$Review)
df$Review <- removeNumbers(df$Review)
df$Review <- tolower(df$Review)
df$Review <- removeWords(df$Review, stopwords('en'))
df$Review <- stripWhitespace(df$Review)
# Remove leading whitespace
df$Review <- gsub("^\\s+", "", df$Review)

tokens <- strsplit(df$Review, split = " ", fixed = T)

# Create vocabulary to remove the words that appear less than 5 times in the vocabulary
vocabulary <- create_vocabulary(itoken(tokens), ngram= c(1,1))
vocabulary <- prune_vocabulary(vocabulary, term_count_min = 5)

# Create a function to filter words based on vocabulary
filter_review <- function(review, vocab) {
  words <- unlist(strsplit(review, " "))  # Split review into words
  filtered_words <- words[words %in% vocab]  # Keep only words present in vocabulary
  filtered_review <- paste(filtered_words, collapse = " ")  # Reconstruct the review
  return(filtered_review)
}

# Remove words from the Review column that are not in the vocabulary
df$Review <- sapply(df$Review, filter_review, vocab = vocabulary$term)

# Create a column called Review_Tokens
df$Review_Tokens <- sapply(df$Review, function(review) tokenize_words(review))

df <- df[, .(isPositive, Review, Review_Tokens)]

end_time <- Sys.time()
# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")

# Write df to a CSV file
fwrite(df, "../data/tokenized_reviews.csv")

# Write the vocabulary to a CSV file
saveRDS(vocabulary, file = "../data/Variables/vocabulary.rds")
