#!/bin/bash
# command line arguments 
# 1: file to translate

export GOOGLE_APPLICATION_CREDENTIALS="/Users/betsysneller/Desktop/mi-covid-diaries/mi covid diaries-31ac6d932f0d.json"

#export GOOGLE_APPLICATION_CREDENTIALS="/Users/mattchurgin/Desktop/mi-covid-diaries/mi covid diaries-31ac6d932f0d.json"

target_dir="/Users/betsysneller/Desktop/mi-covid-diaries/transcripts"
#target_dir="/Users/mattchurgin/Desktop/mi-covid-diaries"

echo "Begin program: "
echo "==============="
input="$1"

file_created=$(date -r "$input" +%F)
full_date_str="$file_created"

echo "${full_date_str}"

pathtofile=`dirname "$input"`
filename=`basename "$input"`

fname="${filename%.*}"

fname_new="${fname// /_}"_${full_date_str}

fname="${fname_new}.wav"

echo "Coverting file to .wav"
echo "==============="
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
python3 google_cloud_speech_transcriber.py gs://mi-covid_diaries-files/"${fname}" $bitrate $target_dir 

# remove file from google cloud bucket
gsutil rm gs://mi-covid_diaries-files/${fname}

echo "Transcription complete and file removed from google cloud bucket"

mv "$input" $target_dir
mv "${fname}" $target_dir

echo "File moved from source directory to $target_dir"
echo "==============="
echo "Done!"
