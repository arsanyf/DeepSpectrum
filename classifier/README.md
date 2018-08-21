# Classification
In the directory `classifier` we put a bash script that runs the classification task using Weka. We also put perl scripts for storing and displaying predictions and scores

## Install Weka
First step is to download and unzip Weka:
```
wget https://sourceforge.net/projects/weka/files/weka-3-8/3.8.2/weka-3-8-2.zip
unzip weka-3-8-2
```

## Install Java
If Java is not installed, install it as follows
```
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:linuxuprising/java
sudo apt-get update
sudo apt-get install oracle-java10-installer

## Install LibLINEAR
```
java -cp /path/to/weka-3-8-2/weka.jar weka.core.WekaPackageManager -install-package LibLINEAR
export CLASSPATH=/path/to/weka-3-8-2/weka.jar:/path/to/wekafiles/packages/LibLINEAR/LibLINEAR.jar:/path/to/wekafiles/packages/LibLINEAR/lib/liblinear-java-1.96-SNAPSHOT.jar
```

## Run Classification Script
```
Convert CSV files that we got from DeepSpectrum into ARFF format.
```
java -Xmx4096m -classpath /path/to/weka.jar weka.core.converters.CSVLoader feature.vector.csv > feature.vector.arff
```
Finally, set the directories for the dataset and the generated results in the file `svm_weka_classifier.sh` lines 9,12, and 17. Then run the script
```
./svm_weka_classifier.sh
```

