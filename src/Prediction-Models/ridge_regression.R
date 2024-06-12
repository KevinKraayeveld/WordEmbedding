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
train_index <- createDataPartition(train$isPositive, p = 0.8, list = FALSE)
train_data <- train[train_index]
test_data <- train[-train_index]

rm(list = c("train_index", "train"))

# Convert Review_Vector column from list to matrix
x_train <- t(sapply(train_data$Review_Vector, unlist))
x_test <- t(sapply(test_data$Review_Vector, unlist))

y_train <- train_data$isPositive
y_test <- test_data$isPositive

rm(list = c("train_data", "test_data"))

# Define the logistic regression model
# Define the ridge regression model using glmnet
ridge_model <- train(
  x = as.data.frame(x_train),
  y = as.factor(y_train),
  method = "glmnet",
  trControl = trainControl(method = "cv", number = 5),  # 5-fold cross-validation
  tuneGrid = expand.grid(alpha = 0, lambda = seq(0.001, 0.1, by = 0.001))  # Ridge regression: alpha = 0
)

# Make predictions on the test data
predictions <- predict(ridge_model, newdata = as.data.frame(x_test), type = "raw")

# Convert predicted probabilities to class labels
#predicted_classes <- ifelse(predictions > 0.5, 1, 0)

# Evaluate the model
confusion_matrix <- table(predictions, as.factor(y_test))

end_time <- Sys.time()

# Total execution time
total_execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("Total execution time:", total_execution_time, "seconds \n")
