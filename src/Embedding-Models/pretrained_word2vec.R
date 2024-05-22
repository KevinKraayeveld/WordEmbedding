library(reticulate)

use_python("C:/Users/kevin/AppData/Local/Programs/Python/Python311/python.exe")

# Install gensim on python
gensim <- import("gensim")

model_path <- "../pretrained_models/GoogleNews-vectors-negative300.bin"
model <- gensim$models$KeyedVectors$load_word2vec_format(model_path, binary = TRUE)

