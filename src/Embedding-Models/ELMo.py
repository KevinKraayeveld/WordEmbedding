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
    df['Review_Embeddings'] = elmo_embeddings(list(df['Review']))
    #test['Review_Embeddings'] = elmo_embeddings(list(test['Review']))
    #print(elmo_embeddings("Hi embed this please"))
    #print(elmo_embeddings(example_sentences))
    end_time = time.time()

    print(f"Time taken: {end_time - start_time:.2f} seconds")

    print(df.head(10))
    
def elmo_embeddings(texts):
    # Define the URL for the ELMo model from TensorFlow Hub
    elmo_model_url = "https://tfhub.dev/google/elmo/3"

    # Create the KerasLayer using the ELMo model URL
    elmo_layer = hub.KerasLayer(elmo_model_url, trainable=False, name="elmo")

    # Compute ELMo embeddings for the input text tensor
    embeddings = elmo_layer(tf.constant(texts))
    embeddings = embeddings.numpy().tolist()

    return embeddings

if __name__ == "__main__":
    main()


