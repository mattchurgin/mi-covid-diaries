#!/bin/bash

echo "Begin program: "
input="$1"
pathtofile=`dirname "$input"`
filename=`basename "$input"`
fname="${filename%.*}"

#echo "${fname}"
fname="${fname// /_}.wav"

# convert file to .wav
ffmpeg -i "${input}" "${fname}"

# copy file to gcloud storage
gsutil cp ${fname} gs://mi-covid_diaries-files/
echo "Successfully completed converting and uploading to google cloud. Converted file is ${fname}"

line=$(file ${fname})
a=( $line )

bitrate=${a[${#a[@]}-2]}

echo $bitrate

echo "Transcribing file"
python3 google_cloud_speech_transcriber.py gs://mi-covid_diaries-files/"${fname}" $bitrate


gsutil rm gs://mi-covid_diaries-files/${fname}

echo "Transcription complete and file removed from google cloud bucket"
