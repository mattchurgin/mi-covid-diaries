
input="$1"



file_created=$(date -r $1)
file_created=( $file_created )
full_date_str=${file_created[0]}${file_created[1]}${file_created[2]}
echo ${file_created[0]}
echo ${file_created[1]}
echo ${full_date_str}
