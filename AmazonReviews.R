library(data.table)
library(tidytext)
library(dplyr)
library(SnowballC)

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

# Make a new data.table without the title
df_review <- df[, Title := NULL]
