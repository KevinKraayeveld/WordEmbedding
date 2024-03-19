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
print(paste("Accuracy:", round(accuracy, 3)))
print(paste("Precision:", round(precision, 3)))
print(paste("Recall:", round(recall, 3)))
print(paste("Specificity:", round(specificity, 3)))
print(paste("F1-score:", round(f1_score, 3)))