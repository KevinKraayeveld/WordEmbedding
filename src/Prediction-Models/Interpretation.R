# Assuming 'model' is your matrix
column_12_values <- model[, 12]  # Extract values from the 12th column

# Sort the values from column 12
sorted_values <- sort(column_12_values)

# Extract top 10 and bottom 10 values
top_10 <- tail(sorted_values, 10)
bottom_10 <- head(sorted_values, 10)

# Print the top and bottom 10 values
print(top_10)
print(bottom_10)

