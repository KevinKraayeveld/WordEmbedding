packages <- c("data.table")

# Check if each package is installed, if not, install it
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

library(data.table)

if (file.exists("../pretrained_models/glove.42B.300d.txt")) {
  model <- fread("../pretrained_models/glove.42B.300d.txt", sep = " ", quote = "")
  row_names <- model[[1]]
  model <- as.matrix(model[, -1, with = FALSE])
  
  rownames(model) <- row_names
  colnames(model) <- NULL
  
  saveRDS(model, "../pretrained_models/pretrained_glove.rds")
  unlink("../pretrained_models/glove.42B.300d.txt")
} else{
  model <- readRDS("../pretrained_models/pretrained_glove.rds")
}

if(small_data){
  train_vocabulary_path <- paste0("../data/variables/", preprocessing_method, "_vocabulary_small.rds")
  vocabulary <- readRDS(train_vocabulary_path)
  test_vocabulary_path <- paste0("../data/variables/", preprocessing_method, "_test_vocabulary_small.rds")
  test_vocabulary <- readRDS(test_vocabulary_path)
} else{
  train_vocabulary_path <- paste0("../data/variables/", preprocessing_method, "_vocabulary.rds")
  vocabulary <- readRDS(train_vocabulary_path)
  test_vocabulary_path <- paste0("../data/variables/", preprocessing_method, "_test_vocabulary.rds")
  test_vocabulary <- readRDS(test_vocabulary_path)
}

full_vocabulary <- union(vocabulary$term, test_vocabulary$term)

rows_to_keep <- rownames(model) %in% full_vocabulary
model <- model[rows_to_keep, , drop = FALSE]

rm(list = c("train_vocabulary_path", "test_vocabulary_path", "vocabulary", 
            "test_vocabulary", "vocabulary", "rows_to_keep", "full_vocabulary"))
