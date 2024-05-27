import pandas as pd
import tensorflow_hub as hub
import tensorflow as tf
import time

def main():
    # path_to_df and path_to_test are defined in the ELMo.R script. They can be used here

    path_to_df = "data/no_stemming_train_small.csv"
    path_to_test = "data/no_stemming_test_small.csv"

    df = pd.read_csv(path_to_df)
    test = pd.read_csv(path_to_test)

    start_time = time.time()
    #df['Review_Embeddings'] = df['Review'].apply(elmo_embeddings)
    test['Review_Embeddings'] = test['Review'].apply(elmo_embeddings)
    #print(elmo_embeddings("Hi embed this please"))
    end_time = time.time()

    print(f"Time taken: {end_time - start_time:.2f} seconds")

    print(test.head(10))
    
def elmo_embeddings(text):
    # Define the URL for the ELMo model from TensorFlow Hub
    elmo_model_url = "https://tfhub.dev/google/elmo/3"

    # Create the KerasLayer using the ELMo model URL
    elmo_layer = hub.KerasLayer(elmo_model_url, trainable=False, name="elmo")

    # Compute ELMo embeddings for the input text tensor
    embeddings = elmo_layer(tf.constant([text]))
    embeddings = embeddings.numpy().tolist()[0]

    return embeddings

if __name__ == "__main__":
    main()


