#!/bin/bash

# set -x

#path to the virtual env
   
#SBATCH --partition=dfl
#SBATCH --time=100:00:00
#SBATCH --mem=30000
#SBATCH --gres=gpu:1
#SBATCH --ntasks=4
#SBATCH --get-user-env
#SBATCH --export=ALL
#SBATCH --mail-type=all
#SBATCH --mail-user=emailaddress@xyz.com
#SBATCH -o /home/amiripar/log-files/ds/social-anxiety/social-anxiety.%A_%a.%N.out
#SBATCH -J ds-social

#batchSize="128"; nfft="256"; ylim="8000"; np="4"; startTime=""; endTime=""
#windowSize="5"; hopSize="0.1"; mode="mel"; 
#windowSize="2"; hopSize="1"; mode="mel"; 
windowSize="2"; hopSize="1"; mode="mel"; nmel="128"; nfft="2048"
#startTime="1"; endTime="3"

task="bip"
outputName="$task-mani-ws_$windowSize-hs_$hopSize-mode_$mode"
#outputName="$task-clip-level-mode_$mode"
taskPath="/ds/experiments"
audioPath="/dataset/audio/Mani/"
#featPath="$taskPath/$task/features/$outputName/$outputName"
featPath="$taskPath/$task/features/Mani/$outputName"
specPath="$taskPath/$task/spectra/Mani/$outputName"
#labels="/home/spa/git/ds/experiments/eat/labels/labels-prepared.csv"

#nets="AlexNet VGG16"
nets="AlexNet"
#layers="fc6 fc7 fc8"
layers="fc6 fc7"
#colorMaps="viridis magma"
colorMaps="viridis"

<<cmt
###################
#one feature file per each audio clip
###################
cd $audioPath
for d in */; do
	for n in $nets; do
		for l in $layers; do
			for c in $colorMaps; do		
				#-specout $specPath -start $startTime -end $endTime
				#with ws and hs
				echo extract_ds_features -f "$audioPath$d" -t $windowSize $hopSize -cmap $c -mode $mode -o "$featPath-net_$n-l_$l-cm_$c/${d%/}.csv" --no_labels -net $n -layer $l -np 4 -nmel $nmel -nfft $nfft 
				#echo extract_ds_features -f "$audioPath$d" -cmap $c -mode $mode -o "$featPath-net_$n-l_$l-cm_$c/${d%/}.csv" --no_labels -net $n -layer $l -np 4 -nmel $nmel -nfft $nfft 
				echo			
				extract_ds_features -f "$audioPath$d" -t $windowSize $hopSize -cmap $c -mode $mode -o "$featPath-net_$n-l_$l-cm_$c/${d%/}.csv" --no_labels -net $n -layer $l -np 4 -nmel $nmel -nfft $nfft 
			done
		done
	done
done
cmt

###################
#one feature file for all audio clips
###################
for n in $nets; do
	for l in $layers; do
		for c in $colorMaps; do		
			#-t $windowSize $hopSize
			echo extract_ds_features -i "$audioPath" -t $windowSize $hopSize -cmap $c -mode $mode -o "$featPath-net_$n-l_$l-cm_$c/$outputName-net_$n-l_$l-cm_$c.csv" -el 1 -net $n -layer $l -np 4 -nmel $nmel -nfft $nfft 
			echo			
			extract_ds_features -i "$audioPath" -t $windowSize $hopSize -cmap $c -mode $mode -o "$featPath-net_$n-l_$l-cm_$c/$outputName-net_$n-l_$l-cm_$c.csv" -el 1 -net $n -layer $l -np 4 -nmel $nmel -nfft $nfft 
		done
	done
done

