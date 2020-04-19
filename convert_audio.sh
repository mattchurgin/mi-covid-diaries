#!/bin/bash

echo "Begin program: "
input="$1"
fname="${input%.*}"
fname="${fname// /_}.wav"

# convert file to .wav
ffmpeg -i "$input" ${fname}

# copy file to gcloud storage
gsutil cp ${fname} gs://mi-covid_diaries-files/
echo "Successfully completed converting and uploading to google cloud. Converted file is ${fname}"
