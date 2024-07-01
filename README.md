## Master Thesis Code - Data Science & Marketing Analytics

This repository contains the code developed by Kevin Kraayeveld for the master thesis in Data Science & Marketing Analytics at Erasmus University Rotterdam.

The code is written to be called from the main.Rmd file in the src folder. In the settings settings cell, you can specify which preprocessing method, embedding method, review vectorization method and prediction method you want to use. You then only have to run each corresponding cell and the correct files will be called in the background.

### Prerequisites

- **R 4.3.1**: Ensure you have R version 4.3.1 installed. You can download it [here](https://cran.r-project.org/).

- **Python 3.11.3**: Make sure Python version 3.11.3 is installed. You can download it [here](https://www.python.org/downloads/release/python-3113/).

### Installation

To install the required Python packages, run the following command:

```bash
pip install -r requirements.txt
```

### Pretrained Models

To utilize pretrained GloVe, fastText, and Word2Vec models, you will need to download them separately:

- **GloVe**: Download pretrained GloVe embeddings from the [official repository](https://nlp.stanford.edu/projects/glove/). Make sure to download the glove.42B.300d.zip file.

- **fastText**: Download the pretrained fastText embeddings from the [official website](https://fasttext.cc/docs/en/english-vectors.html). Make sure to download the crawl-300d-2M-subword.zip file.

- **Word2Vec**: Download the pre-trained word2vec model from [Word2Vec Google News GitHub](https://github.com/mmihaltz/word2vec-GoogleNews-vectors).

Make sure to place these pretrained models pretrained_models folder for the code to work.

### Usage

Once you have installed the prerequisites and downloaded the pretrained models, you can proceed to run the code as per your requirements.

For further details on the project and methodology, refer to the master thesis document provided with this repository.
