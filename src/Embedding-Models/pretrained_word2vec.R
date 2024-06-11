library(reticulate)

use_python(python_path)

# Install gensim on python
gensim <- import("gensim")

model_path <- "../pretrained_models/GoogleNews-vectors-negative300.bin"
model <- gensim$models$KeyedVectors$load_word2vec_format(model_path, binary = TRUE)

