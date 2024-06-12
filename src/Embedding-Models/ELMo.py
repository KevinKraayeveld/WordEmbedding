import pandas as pd
import tensorflow_hub as hub
import tensorflow as tf
import time
import os
import numpy as np

# Define the URL for the ELMo model from TensorFlow Hub
elmo_model_url = "https://tfhub.dev/google/elmo/3"

# Create the KerasLayer using the ELMo model URL
elmo_layer = hub.KerasLayer(elmo_model_url, trainable=False, name="elmo")

def main():
    os.chdir("C:/Users/kevin/Desktop/Master-Thesis/Wordembedding/src")

    small_data = True
    preprocessing_method = "complete_cleaning"

    # small_data and preprocessing_method are defined in the python environment in the ELMo.R script. They can be used here
    if small_data:
        path_to_train = f"../data/Cleaned-Reviews/{preprocessing_method}_train_small.csv"
        path_to_test = f"../data/Cleaned-Reviews/{preprocessing_method}_test_small.csv"
    else:
        path_to_train = f"../data/Cleaned-Reviews/{preprocessing_method}_train.csv"
        path_to_test = f"../data/Cleaned-Reviews/{preprocessing_method}_test.csv"

    train = pd.read_csv(path_to_train)
    test = pd.read_csv(path_to_test)

    start_time = time.time()
    train['Review_Vector'] = elmo_embeddings(list(train['Review']))
    test['Review_Vector'] = elmo_embeddings(list(test['Review']))
    end_time = time.time()

    print(f"Time taken: {end_time - start_time:.2f} seconds")

    train = train.drop(columns=['Review'])
    test = test.drop(columns=['Review'])

    if small_data:
        train.to_csv(f"../data/Cleaned-Reviews/{preprocessing_method}_elmo_train_small.csv", index = False)
        test.to_csv(f"../data/Cleaned-Reviews/{preprocessing_method}_elmo_test_small.csv", index = False)
    else:
        train.to_csv(f"../data/Vectorized-Reviews/{preprocessing_method}_elmo_train.csv", index = False)
        test.to_csv(f"../data/Vectorized-Reviews/{preprocessing_method}_elmo_test.csv", index = False)
    
def elmo_embeddings(texts):
    # Compute ELMo embeddings for the input text tensor
    embeddings = elmo_layer(tf.constant(texts))
    embeddings = embeddings.numpy().tolist()

    return embeddings

if __name__ == "__main__":
    main()


