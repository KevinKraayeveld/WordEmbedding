# List of required packages
packages <- c("tidytext", "textdata", "dplyr", "tidyverse")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(data.table)
library(tidytext)
library(textdata)
library(dplyr)
library(tidyverse)

# Convert data.table to data frame for tidytext compatibility
df <- as.data.frame(df)
test <- as.data.frame(test)

# Add an ID column to keep track of the original reviews
df <- df %>% mutate(review_id = row_number())
test <- test %>% mutate(review_id = row_number())

# Unnest tokens directly from the Review column
df_tokens <- df %>%
  unnest_tokens(word, Review)
test_tokens <- test %>%
  unnest_tokens(word, Review)

# Get sentiment lexicon
sentiments <- get_sentiments("bing")

# Perform sentiment analysis
sentiment_analysis <- df_tokens %>%
  inner_join(sentiments, by = "word") %>%
  count(review_id, sentiment) %>%
  spread(sentiment, n, fill = 0)
sentiment_analysis_test <- test_tokens %>%
  inner_join(sentiments, by = "word") %>%
  count(review_id, sentiment) %>%
  spread(sentiment, n, fill = 0)

sentiment_analysis <- sentiment_analysis %>%
  mutate(positive = ifelse(is.na(positive), 0, positive),
         negative = ifelse(is.na(negative), 0, negative)) %>%
  mutate(sentiment_score = positive - negative)
sentiment_analysis_test <- sentiment_analysis_test %>%
  mutate(positive = ifelse(is.na(positive), 0, positive),
         negative = ifelse(is.na(negative), 0, negative)) %>%
  mutate(sentiment_score = positive - negative)

# Ensure all reviews have a sentiment score
sentiment_analysis <- sentiment_analysis %>%
  right_join(data.frame(review_id = 1:nrow(df)), by = "review_id") %>%
  replace_na(list(positive = 0, negative = 0, sentiment_score = 0))
sentiment_analysis_test <- sentiment_analysis_test %>%
  right_join(data.frame(review_id = 1:nrow(test)), by = "review_id") %>%
  replace_na(list(positive = 0, negative = 0, sentiment_score = 0))

# Add sentiment scores to the original data
df_sentiments <- df %>%
  mutate(sentiment_score = sentiment_analysis$sentiment_score)
test_sentiments <- test %>%
  mutate(sentiment_score = sentiment_analysis_test$sentiment_score)

# Convert back to data.table
df <- as.data.table(df_sentiments)
test <- as.data.table(test_sentiments)

df[, c("Review", "Review_Tokens", "review_id") := NULL]
test[, c("Review", "Review_Tokens", "review_id") := NULL]

df <- df %>%
  mutate(prediction = case_when(
    sentiment_score < 0 ~ FALSE,
    sentiment_score > 0 ~ TRUE,
    sentiment_score == 0 ~ sample(c(TRUE, FALSE), size = n(), replace = TRUE)
  ))

#logistic_model <- glm(isPositive ~ sentiment_score, data = df, family = binomial)

# Predicting the probabilities
#predictions <- predict(logistic_model, newdata = test, type = "response")

# Convert predicted probabilities to class labels
#predicted_classes <- ifelse(predictions > 0.5, 1, 0)

# Evaluate the model
#confusion_matrix <- table(predicted_classes, test$isPositive)

confusion_matrix <- table(df$prediction, df$isPositive)

