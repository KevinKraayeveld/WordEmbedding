import pandas as pd
import tensorflow_hub as hub
import tensorflow as tf
import time
import os
import kagglehub

elmo_model = kagglehub.model_download("google/elmo/tensorFlow1/elmo")

# Create the KerasLayer using the ELMo model URL
elmo_layer = hub.KerasLayer(elmo_model, trainable=False, name="elmo")

def main():
    os.chdir("C:/Users/kevin/Desktop/Master-Thesis/Wordembedding/src")

    small_data = True
    preprocessing_method = "complete_cleaning"

    # small_data and preprocessing_method are defined in the python environment in the ELMo.R script. 
    # They can be used here if this file is called from that script.
    if small_data:
        path_to_train = f"../data/Cleaned-Reviews/{preprocessing_method}_train_small.csv"
        path_to_test = f"../data/Cleaned-Reviews/{preprocessing_method}_test_small.csv"
    else:
        path_to_train = f"../data/Cleaned-Reviews/{preprocessing_method}_train.csv"
        path_to_test = f"../data/Cleaned-Reviews/{preprocessing_method}_test.csv"

    train = pd.read_csv(path_to_train)
    test = pd.read_csv(path_to_test)

    train_embeddings = []
    test_embeddings = []

    start_time = time.time()

    batch_size = 500

    print("Embed train reviews")
    for i in range(0, len(train), batch_size):
        batch = train['Review'].iloc[i:i+batch_size].tolist()
        embeddings = elmo_embeddings(batch)
        train_embeddings.extend(embeddings)

    print("Embed test reviews")
    for i in range(0, len(test), batch_size):
        batch = test['Review'].iloc[i:i+batch_size].tolist()
        embeddings = elmo_embeddings(batch)
        test_embeddings.extend(embeddings)

    train['Review_Vector'] = train_embeddings
    test['Review_Vector'] = test_embeddings
    end_time = time.time()

    print(f"Time taken: {end_time - start_time:.2f} seconds")

    train = train.drop(columns=['Review', 'Review_Tokens'])
    test = test.drop(columns=['Review', 'Review_Tokens'])

    if small_data:
        train.to_csv(f"../data/Vectorized-Reviews/{preprocessing_method}_elmo_train_small.csv", index = False)
        test.to_csv(f"../data/Vectorized-Reviews/{preprocessing_method}_elmo_test_small.csv", index = False)
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


