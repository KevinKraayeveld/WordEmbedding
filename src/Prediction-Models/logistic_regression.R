# List of required packages
packages <- c("data.table", "caret")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

# Importing required libraries
library(data.table)
library(caret)

start_time <- Sys.time()

# Split the data into training and testing sets (20/80 split)
set.seed(123)  # For reproducibility
train_index <- createDataPartition(df$isPositive, p = 0.8, list = FALSE)
train_data <- df[train_index]
test_data <- df[-train_index]

# Convert Review_Vector column from list to matrix
x_train <- t(sapply(train_data$Review_Vector, unlist))
x_test <- t(sapply(test_data$Review_Vector, unlist))

y_train <- train_data$isPositive
y_test <- test_data$isPositive

# Define the logistic regression model
logit_model <- glm(y_train ~ ., data = as.data.frame(x_train), family = binomial)

# Make predictions on the test data
predictions <- predict(logit_model, newdata = as.data.frame(x_test), type = "response")

# Convert predicted probabilities to class labels
predicted_classes <- ifelse(predictions > 0.5, 1, 0)

# Evaluate the model
confusion_matrix <- table(predicted_classes, y_test)

end_time <- Sys.time()

# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time:", total_execution_time, "seconds \n")
cat("Estimated execution time for full dataset is", total_execution_time*(4000000/nrow(df)), 
    "seconds. Which is", total_execution_time*(4000000/nrow(df))/3600, "hours \n")
