#!/bin/sh

# Bip Data, Mani Level Classification
# Baseline script: training on training set using leave-one-foldect-out (LOSO) cross-validation

#set -x

# path to your feature directory (ARFF files)
feat_dir=/datasets/csvdata/nominal

# directory where SVM models will be stored
model_dir=/home/ga83mix2/ds/classification/models/train_loso
rm -rf $model_dir
mkdir -p $model_dir

# directory where evaluation results will be stored
eval_dir=/home/ga83mix2/ds/classification/eval/train_loso
rm -rf $eval_dir
mkdir -p $eval_dir

# feature file basename
feat_name=fold

# path to Weka's jar file
weka_jar="/home/ga83mix2/weka-3-8-2/weka.jar"
test -f "$weka_jar" || exit -1

# memory to allocate for the JVM
jvm_mem=8192m

# SVM complexity constant
C=$1
test -z "$C" && C=1.0E-5

#epsilon-intensive loss
L=$2
test -z "$L" && L=0.1

#feature-variant
#V=$3
#test -z "$V" && V="fused"

#if [ "$V" = "fused" ]; then
lab_nominal=4098 # because I already removed the name column in preprocessing
lab_numeric=4099
#else
#	lab_nominal=1027
#	lab_numeric=1028
#fi

arffs=
preds=
uars=

fold_ids="0 1 2 3" # fold 1-4

for fold in $fold_ids; do
	# concert CSV to ARFF
	#echo "java -Xmx$jvm_mem -classpath $weka_jar weka.core.converters.CSVLoader $feat_dir/$feat_name.$fold.tr.csv > $feat_dir/$feat_name.$fold.tr.arff"
	#java -Xmx$jvm_mem -classpath $weka_jar weka.core.converters.CSVLoader $feat_dir/$feat_name.$fold.tr.csv > $feat_dir/$feat_name.$fold.tr.arff
	#echo "java -Xmx$jvm_mem -classpath $weka_jar weka.core.converters.CSVLoader $feat_dir/$feat_name.$fold.te.csv > $feat_dir/$feat_name.$fold.te.arff"
	#java -Xmx$jvm_mem -classpath $weka_jar weka.core.converters.CSVLoader $feat_dir/$feat_name.$fold.te.csv > $feat_dir/$feat_name.$fold.te.arff

	train_arff=$feat_dir/$feat_name.$fold.tr.arff
	#train_arff_up=$feat_dir/$feat_name.$fold.tr.upsampled.arff
	test_arff=$feat_dir/$feat_name.$fold.te.arff

	echo "foldect $fold"
    
	# Upsampling of train
	#test -f $train_arff_up || perl upsample.pl $train_arff $train_arff_up "train"

	# model file name
	svm_model_name=$model_dir/$feat_name.train.SMO.C$C.L$L.$fold.model

	# train SVM using Weka's SMO, using FilteredClassifier wrapper to ignore first attribute (instance name)

	echo "java -Xmx$jvm_mem -classpath $weka_jar weka.classifiers.meta.FilteredClassifier -v -o -no-cv -c last -t $train_arff -d $svm_model_name -F weka.filters.unsupervised.attribute.Remove -R 1 -W weka.classifiers.functions.SMO -- -C $C -L $L -N 1 -M -P 1.0E-12 -V -1 -W 1 -K weka.classifiers.functions.supportVector.PolyKernel -C 250007 -E 1.0 || exit 1"
	java -Xmx$jvm_mem -classpath "$weka_jar" weka.classifiers.meta.FilteredClassifier -v -o -no-cv -c last -t "$train_arff" -d "$svm_model_name" -F "weka.filters.unsupervised.attribute.Remove -R 1" -W weka.classifiers.functions.SMO -- -C $C -L $L -N 1 -M -P 1.0E-12 -V -1 -W 1 -K "weka.classifiers.functions.supportVector.PolyKernel -C 250007 -E 1.0" || exit 1
	echo "finished train model"

	# evaluate SVM and write predictions
	pred_file=$eval_dir/$feat_name.SMO.C$C.L$L.$fold.pred
	if [ ! -s "$pred_file" ]; then
		java -Xmx$jvm_mem -classpath "$weka_jar" weka.classifiers.meta.FilteredClassifier -o -c $lab_nominal -l "$svm_model_name" -T "$test_arff" -p 0 -distribution > "$pred_file" || exit 1
	fi

	echo "finished evaluate SVM and write predictions"

        arffs="$arffs $test_arff"
        preds="$preds $pred_file"

        # calculate classification scores for foldect
        perl format_pred.pl $test_arff $pred_file tmp$$.arff $lab
        perl score.pl $test_arff tmp$$.arff $lab
        uar=`perl score.pl $test_arff tmp$$.arff $lab | grep ^UAR | cut "-d=" -f2`
        uars="$uars $uar"
        echo "UAR: $uar"
	echo 
        rm tmp$$.arff
done

# produce ARFF file in submission format
pred_arff=$eval_dir/$feat_name.SMO.C$C.L$L.arff
test -f $pred_arff || perl format_pred.pl $arffs $preds $pred_arff $lab

echo
echo "Leave-one-foldect-out cross-validation (LOSO CV)"

# calculate classification scores for all foldects
ref_arff=../arff/$feat_name.train.arff
result_file=$eval_dir/`basename $pred_arff .arff`.result
if [ ! -s $result_file ]; then
    perl score.pl $ref_arff $pred_arff $lab | tee $result_file
else
    cat $result_file
fi

# display mean / stddev of UARs per foldect (cf. loop above)
echo 
echo Mean UAR per foldect:
echo $uars | perl mean_sd.pl

