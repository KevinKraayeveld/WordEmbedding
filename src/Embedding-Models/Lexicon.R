# List of required packages
packages <- c("vader", "data.table", "dplyr")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(vader)
library(data.table)
library(dplyr)

rm(train)
test[, Review_Tokens := NULL]

start_time <- Sys.time()

# Analyze sentiment using VADER
sentiment_scores <- vader_df(test$Review)

end_time <- Sys.time()

test[, Review := NULL]

print(paste("Computation time VADER lexicon:", round(end_time - start_time, 2), "seconds"))

sentiment_scores <- sentiment_scores$compound

test <- test %>%
  mutate(prediction = case_when(
    sentiment_scores < 0 ~ FALSE,
    sentiment_scores > 0 ~ TRUE,
    sentiment_scores == 0 ~ sample(c(TRUE, FALSE), size = n(), replace = TRUE)
  ))

confusion_matrix <- table(test$prediction, test$isPositive)
