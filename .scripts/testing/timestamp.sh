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
  echo "${SSI[i]}" 
  echo "${TO2[i]}" 
  echo "${OUT[i]}.mp3"
done

# Print only timestamps and dedup
#ffprobe -loglevel 'error' -show_entries 'stream_tags : format_tags' '/home/zerohack/Music/The Messenger (Original Soundtrack) Disc 2： The Future [16-bit] [i56wbutAhGA].mp3' | grep "[[:digit:]]:[[:digit:]]:*" | awk '! seen[$0]++' | awk 'NF>1{print $NF}'
# Remove the timestamp at last
#ffprobe -loglevel 'error' -show_entries 'stream_tags : format_tags' '/home/zerohack/Music/The Messenger (Original Soundtrack) Disc 2： The Future [16-bit] [i56wbutAhGA].mp3' | grep "[[:digit:]]:[[:digit:]]:*" | awk '! seen[$0]++' | awk '{$NF=""}1'
#cat timestamp_file | awk 'NF>1{print }'
#result=$(echo $line | awk 'NF>1{print $NF}')
#result=("$(echo $line | awk 'NF>1{print $NF}')"); sleep 5; echo $result
