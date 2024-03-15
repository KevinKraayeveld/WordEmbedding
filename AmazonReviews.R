library(data.table)
library(tidytext)
library(dplyr)

# Read data as data.table
train <- fread("../Data/AmazonReviews/train.csv")
test <- fread("../Data/AmazonReviews/test.csv")

# Change variable names
setnames(train, old = c("V1", "V2", "V3"), new = c("isPositive", "Title", "Review"))
setnames(test, old = c("V1", "V2", "V3"), new = c("isPositive", "Title", "Review"))

# Make positive value 1 and negative value 0
train$isPositive <- train$isPositive - 1
test$isPositive <- test$isPositive - 1

# Transform the isPositive variable to a logical variable
train$isPositive <- as.logical(train$isPositive)
test$isPositive <- as.logical(test$isPositive)

# Temporary dataset to test code on
df <- head(train, 1000)

# Turn the Title and Review to all lower case.
df$Title <- tolower(df$Title)
df$Review <- tolower(df$Review)

# Remove punctuation from Title and Review
df$Title <- gsub("[[:punct:]]", "", df$Title)
df$Review <- gsub("[[:punct:]]", "", df$Review)

# Get stop_words from the tidytext package
data(stop_words)

# Remove stop words function
remove_stopwords <- function(text) {
  # Split the text into individual words
  words <- unlist(strsplit(text, " "))
  # Remove stop words
  words <- words[!tolower(words) %in% stop_words$word]
  # Combine the words back into a single string
  cleaned_text <- paste(words, collapse = " ")
  return(cleaned_text)
}

# Remove stop words from the Review column
df[, Review := lapply(Review, remove_stopwords)]

# Remove stop words from the Title column
df[, Title := lapply(Title, remove_stopwords)]

# Tokenize the Review
df$Review_Tokens <- sapply(df$Review, function(x) tokenize_words(x))
df$Title_Tokens <- sapply(df$Title, function(x) tokenize_words(x))

# Write df to a CSV file
fwrite(df, "cleaned_data.csv")
