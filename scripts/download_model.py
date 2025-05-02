import os
import urllib.request

def download_model():
    # Create models directory if it doesn't exist
    os.makedirs('assets/models', exist_ok=True)
    
    # Download MobileNet model
    model_url = 'https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v1_1.0_224_quant_and_labels.zip'
    model_path = 'assets/models/mobilenet.zip'
    
    print('Downloading model...')
    urllib.request.urlretrieve(model_url, model_path)
    print('Model downloaded successfully!')

if __name__ == '__main__':
    download_model() 