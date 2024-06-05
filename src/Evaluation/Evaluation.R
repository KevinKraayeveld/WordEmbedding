TN <- confusion_matrix[[1]]
TP <- confusion_matrix[, 2][[2]]
FP <- confusion_matrix[[2]]
FN <- confusion_matrix[, 2][[1]]

print(confusion_matrix)

# Calculate measures
accuracy <- (TP + TN) / (TP + TN + FP + FN)
precision <- TP / (TP + FP)
recall <- TP / (TP + FN)
specificity <- TN / (TN + FP)
f1_score <- 2 * (precision * recall) / (precision + recall)

# Print results
print(paste("Accuracy:", round(accuracy, 4)))
print(paste("Precision:", round(precision, 4)))
print(paste("Recall:", round(recall, 4)))
print(paste("Specificity:", round(specificity, 4)))
print(paste("F1-score:", round(f1_score, 4)))