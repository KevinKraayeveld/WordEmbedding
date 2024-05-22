library(data.table)

if (file.exists("../pretrained_models/glove.840B.300d.txt")) {
  model <- fread("../pretrained_models/glove.840B.300d.txt", sep = " ", quote = "")
  row_names <- model[[1]]
  model <- as.matrix(model[, -1, with = FALSE])
  
  rownames(model) <- row_names
  colnames(model) <- NULL
  
  saveRDS(model, "../pretrained_models/pretrained_glove.rds")
  unlink("../pretrained_models/glove.840B.300d.txt")
} else{
  model <- readRDS("../pretrained_models/pretrained_glove.rds")
}

if(small_data){
  vocabulary <- readRDS("../data/variables/vocabulary_small.rds")
  test_vocabulary <- readRDS("../data/variables/test_vocabulary_small.rds")
} else{
  vocabulary <- readRDS("../data/variables/vocabulary.rds")
  test_vocabulary <- readRDS("../data/variables/test_vocabulary.rds")
}

full_vocabulary <- union(vocabulary$term, test_vocabulary$term)

rows_to_keep <- rownames(model) %in% full_vocabulary
model <- model[rows_to_keep, , drop = FALSE]
