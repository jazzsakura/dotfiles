#!/usr/bin/env bash
# split.sh

if [ $# -eq 0 ]; then
    >&2 echo "Usage: $(basename $0) [TIMESTAMP_FILE] [MP3_FILE]"
    exit 1
fi

duration=$(ffmpeg -i $2 2>&1 | awk '/Duration/ { print substr($2,0,length($2)-1) }')

SSI=()
TOI=()
OUT=()
while IFS= read -r line; do
  SSI+=("$(echo $line | awk 'NF>1{print $NF}')")
  TOI+=("$(echo $line | awk 'NF>1{print $NF}')")
  OUT+=("${line#* }")
done < $1 # Timestamp file

unset 'TOI[0]'
TO2=()
for i in "${!TOI[@]}"; do
  TO2+=("${TOI[i]}")
done

TO2+=("${duration%%.*}")

for i in "${!OUT[@]}"; do
  ffmpeg -ss "${SSI[i]}" -to "${TO2[i]}" -i "$2" -c:a copy "${OUT[i]}.mp3"
done
