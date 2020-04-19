#!/bin/bash

export GOOGLE_APPLICATION_CREDENTIALS="/Users/betsysneller/Desktop/mi-covid-diaries/mi covid diaries-31ac6d932f0d.json"

echo "Begin program: "
echo "==============="
input="$1"
pathtofile=`dirname "$input"`
filename=`basename "$input"`
fname="${filename%.*}"

#echo "${fname}"
fname="${fname// /_}.wav"

echo "Coverting file to .wav"
echo "==============="
# convert file to .wav
ffmpeg -i "${input}" "${fname}"

echo "Uploading to google cloud bucket"
echo "==============="

# copy file to gcloud storage
gsutil cp ${fname} gs://mi-covid_diaries-files/
echo "Successfully completed converting and uploading to google cloud. Converted file is ${fname}"
echo "==============="

line=$(file ${fname})
a=( $line )

bitrate=${a[${#a[@]}-2]}

echo "bit rate:  $bitrate"

echo "Transcribing file"
echo "==============="
python3 google_cloud_speech_transcriber.py gs://mi-covid_diaries-files/"${fname}" $bitrate

# remove file from google cloud bucket
gsutil rm gs://mi-covid_diaries-files/${fname}

echo "Transcription complete and file removed from google cloud bucket"
echo "==============="
echo "Done!"
