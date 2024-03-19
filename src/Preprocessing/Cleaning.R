library(data.table)
library(text2vec)
library(tm)
library(tokenizers)
library(SnowballC)
library(hash)

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
sample_indices <- sample(total_rows, 20000)
df <- df[sample_indices]

start_time <- Sys.time()

# Remove stop words, punctuation, whitespace, numbers and make everything lower case
print("Start removing punctiation")
df$Review <- removePunctuation(df$Review)
print("Finished removing punctuation, starting to remove numbers")
df$Review <- removeNumbers(df$Review)
print("Removed numbers, now turning everything lowercase")
df$Review <- tolower(df$Review)
print("Everything is now lowercase. Removing stopwords")
df$Review <- removeWords(df$Review, stopwords('en'))
print("Removed stopwords, now removing whitespace")
df$Review <- stripWhitespace(df$Review)
print("Now removing whitespaces at the first index")
df$Review <- gsub("^\\s+", "", df$Review)

print("Creating tokens")
tokens <- strsplit(df$Review, split = " ", fixed = T)

# Stem the tokens
print("Stemming tokens")
tokens <- lapply(tokens, function(token_list) wordStem(token_list, language = "en"))

# Create vocabulary to remove the words that appear less than 5 times in the vocabulary
print("Creating vocabulary")
vocabulary <- create_vocabulary(itoken(tokens), ngram= c(1,1))
print("Pruning vocabulary")
vocabulary <- prune_vocabulary(vocabulary, term_count_min = 5)

print("Removing tokens that are not in the pruned vocabulary")
remove_tokens <- Sys.time()
tokens <- lapply(tokens, intersect, y = vocabulary$term)
end_remove_tokens <- Sys.time()
total_execution_time_tokens <- as.numeric(difftime(end_remove_tokens, remove_tokens, units = "secs"))
print(paste("Execution time of removing tokens", total_execution_time_tokens))


# Put the tokens list in the data.table in a column called Review_Tokens
print("Putting the tokens in the df")
df$Review_Tokens <- tokens

print("Removing unnecessary columns")
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
