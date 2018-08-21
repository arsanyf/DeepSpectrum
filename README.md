Based on https://github.com/DeepSpectrum/DeepSpectrum


**DeepSpectrum** is a Python toolkit for feature extraction from audio data with pre-trained Image Convolutional Neural Networks (CNNs). It features an extraction pipeline which first creates visual representations for audio data - plots of spectrograms or chromagrams - and then feeds them to a pre-trained Image CNN. Activations of a specific layer then form the final feature vectors.

**(c) 2017-2018 Shahin Amiriparian, Maurice Gerczuk, Sandra Ottl, Björn Schuller: Universität Augsburg**
Published under GPLv3, see the LICENSE.md file for details.

Please direct any questions or requests to Shahin Amiriparian (shahin.amiriparian at tum.de) or Maurice Gercuk (gerczuk at fim.uni-passau.de).

# Citing
If you use DeepSpectrum or any code from DeepSpectrum in your research work, you are kindly asked to acknowledge the use of DeepSpectrum in your publications.
> S. Amiriparian, M. Gerczuk, S. Ottl, N. Cummins, M. Freitag, S. Pugachevskiy, A. Baird and B. Schuller. Snore Sound Classification using Image-Based Deep Spectrum Features. In Proceedings of INTERSPEECH (Vol. 17, pp. 2017-434)


# Installation
This program supports pipenv for dependency resolution and installation and we highly recommend you to use it. In addition to the actual tool in `deep-spectrum` there is also another tool which helps with aquiring the pre-trained AlexNet model and converting it to a tensorflow compatible format. This relies on the `caffe-tensorflow` conversion tool found at https://github.com/ethereon/caffe-tensorflow 

## Python installation
This installs python3.6 and the image libraries necessary for `imread` to install successfully.
```
sudo add-apt-repository ppa:jonathonf/python-3.6
sudo apt-get update
sudo apt-get install -y python3.6 python3.6-dev libjpeg-dev libpng-dev libtiff-dev
```
## Install CUDA
```
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
sudo apt-get update
sudo apt-get install -y cuda=9.0.176-1
```

## Install cuDNN
```
wget http://developer.download.nvidia.com/compute/redist/cudnn/v7.1.2/cudnn-9.0-linux-x64-v7.1.tgz
tar -xvf cudnn-9.0-linux-x64-v7.1.tgz
sudo cp -P cuda/include/cudnn.h /usr/local/cuda-9.0/include
sudo cp -P cuda/lib64/libcudnn* /usr/local/cuda-9.0/lib64/
sudo chmod a+r /usr/local/cuda-9.0/lib64/libcudnn*
export PATH=/usr/local/cuda-9.0/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-9.0/lib64
```


## Dependencies
* Python 3.6 with pipenv for the Deep Spectrum tool (`pip install pipenv`)
* Python 2.7 to download and convert the AlexNet model

## Download and convert AlexNet model
The Deep Spectrum tool uses the ImageNet pretrained AlexNet model to extract features. To download and convert it to a tensorflow compatible format, a script `download_alexnet.sh` is included. The script performs these general steps:
1. Create a python2 virtual environment with tensorflow in `convert-models/`
2. Clone the caffe-tensorflow repository (https://github.com/ethereon/caffe-tensorflow) that is later used to convert the model
3. Fix incompatibilities of the repository with new tensorflow versions
4. Download the model files from https://github.com/BVLC/caffe/tree/master/models/bvlc_alexnet
5. Run the conversion script `convert-models/caffe-tensorflow/convert.py` to convert the weights to .npy format
6. Load the model into a tensorflow graph and save it to `.pb` format (`convert_to_pb.py`)
7. Move the file to `deep-spectrum/AlexNet.pb`

## Deep Spectrum tool
Install the Deep Spectrum tool from the `deep-spectrum/` directory with pipenv (which also handles the creation of a virtualenv for you):
```bash
cd deep-spectrum
pipenv --site-packages install
pipenv install tensorflow-gpu==1.8.0
```

# Generate Feature Vectors
We provide 2 scripts under `deep-spectrum`: `bip-extract-features-kont.sh` and `bip-extract-features-mani.sh`. Each script generates 2 feature vector CSV files, one fore fc6 and the other fc7. Note that the Mani script can generate a vectors with the same label 1 that indicates that the sample is mani. It is possible to make the label as the mania level by adjusting the dataset directory as follows:
```
Mani                          Base Directory of your data
  ├─── 1                      Directory containing members of mani level 1
  |    └─── instanceX.wav     
  ├─── 2                      Mani level 2
  |    └─── instanceY.wav     
  └─── 3                      Mani level 3
       └─── instanceZ.wav  
```

# Classification
In the directory `classifier` we put a bash script that runs the classification task using Weka. We also put perl scripts for storing and displaying predictions and scores

## Install Weka
First step is to download and unzip Weka:
```
wget https://sourceforge.net/projects/weka/files/weka-3-9/3.9.2/weka-3-9-2.zip
unzip weka-3-9-2
```
Then install java:
```
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:linuxuprising/java
sudo apt-get update
sudo apt-get install oracle-java10-installer
```
Convert CSV files that we got from DeepSpectrum into ARFF format.
```
java -Xmx4096m -classpath /path/to/weka.jar weka.core.converters.CSVLoader feature.vector.csv > feature.vector.arff
```
Finally, set the directories for the dataset and the generated results in the file `svm_weka_classifier.sh` lines 9,12, and 17. Then run the script
```
./svm_weka_classifier.sh
```
