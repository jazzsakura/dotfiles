#!/usr/bin/env bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_updated() {
    echo -e "${CYAN}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

update_inodes() {
  stat -c %Z $THUMBDIR > "$THUMBDIR/last_inode"
  stat -c %Z $VIDEODIR > "$VIDEODIR/last_inode"
}

check_bgm_db() {
  ag -f -i --hidden --ignore '.gitignore' --ignore-dir '.*git*' -g '' $VIDEODIR 2>/dev/null | xargs -P0 -I{} basename {} | grep -E '.mp4$' > $LIST2
  awk 'NR==FNR {seen[$0];next} !($0 in seen) { seen[$0];print }' $LIST2 $LIST1 > $TEMPFILE1
  if [[ ! -s "$TEMPFILE1" && $INODE1 -eq "$(cat $THUMBDIR/last_inode)" ]]; then
      awk 'NR==FNR {seen[$0];next} !($0 in seen) { seen[$0];print }' $LIST1 $LIST2 | sed "s@^@$VIDEODIR/@" > $TEMPFILE2
      cat $TEMPFILE2 | xargs -P0 -I{} ffmpeg -hwaccel vdpau -y -ss 00:00:05 -i {} -vframes 1 -q:v 2 {}.jpg
      cat $TEMPFILE2 | xargs -P0 -I{} mv {}.jpg $THUMBDIR
      update_inodes
      cat $LIST2 > $LIST1
  else 
    if [[ $INODE1 -eq "$(cat $THUMBDIR/last_inode)" ]]; then 
      rm "$THUMBDIR/$(cat $TEMPFILE1).jpg"
      update_inodes
      cat $LIST2 > $LIST1
    fi
  fi
}

clean_files() {
  rm $TEMPFILE1
  rm $TEMPFILE2
}

TEMPFILE1=$(mktemp)
TEMPFILE2=$(mktemp)
THUMBDIR="$HOME/Pictures/mp4-thumbs"
VIDEODIR="$HOME/Pictures/motionbgs"
LIST1="$THUMBDIR/thumbnails"
LIST2="$VIDEODIR/movwalls"
INODE1="$(stat -c %Z $THUMBDIR)"
INODE2="$(stat -c %Z $VIDEODIR)"

if [[ ! -f "$LIST1" ]]; then
  ag -f -i --hidden --ignore '.gitignore' --ignore-dir '.*git*' -g '' $THUMBDIR 2>/dev/null | grep -E '.mp4$' > $LIST1
  stat -c %Z $THUMBDIR > "$THUMBDIR/last_inode"
  if [[ ! -f "$LIST2" && ! -s "$LIST1" ]]; then
  ag -f -i --hidden --ignore '.gitignore' --ignore-dir '.*git*' -g '' $VIDEODIR 2>/dev/null | grep -E '.mp4$' > $LIST2
  cat $LIST2 | xargs -P0 -I{} basename {} > $LIST1
  cat $LIST2 | xargs -P0 -I{} ffmpeg -hwaccel vdpau -y -ss 00:00:05 -i {} -vframes 1 -q:v 2 {}.jpg
  cat $LIST2 | xargs -P0 -I{} mv {}.jpg $THUMBDIR
  update_inodes
else
  if [[ ! $INODE2 -eq "$(cat $VIDEODIR/last_inode)" ]]; then
    check_bgm_db
  fi
fi
elif [[ ! $INODE2 -eq "$(cat $VIDEODIR/last_inode)" ]]; then
  check_bgm_db
elif [[ ! $INODE1 -eq "$(cat $THUMBDIR/last_inode)" ]]; then
  ag -i --hidden --ignore '.gitignore' --ignore-dir '.*git*' -g '' $THUMBDIR 2>/dev/null | xargs -P0 -I{} basename {} | grep -E '.jpg$' | sed 's/\.[^.]*$//' > $LIST1
  update_inodes
fi

clean_files

wallDir="${HOME}/Pictures/mp4-thumbs"
#export wallSet="${HOME}/.config/niri/wall.jpg"
movSet="$HOME/Pictures/motionbgs"
export homeDir="${PWD}"

IMG=$(rg --color never -L -u --hidden --no-config --files --glob '!.*git*' --glob '!.npm*' $wallDir |
shuf |
sed -nE '/.*\.(jpg|jpeg|png|gif|bmp|mp4)$/Ip' |
fzf --bind 'j:down,k:up' --preview 'kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no {}' --preview-window 'up,99%,border-none,noinfo' --reverse --header-first --inline-info --prompt='' --no-sort --no-input --info='hidden' |
xargs basename | sed 's/\.[^.]*$//')

DIR=$(rg --color never -L -u --hidden --no-config --files --glob '!.*git*' --glob '!.npm*' $movSet | sed -nE '/.*\.(jpg|jpeg|png|gif|bmp|mp4)$/Ip' | grep -i $IMG)

if [ -z "$DIR" ]; then
  exit 0
else
  #ln -fs "${IMG}" "${wallSet}"
  pgrep -f mpvpaper && pkill -f mpvpaper
  systemd-run --user --no-block bash -c "nohup mpv ${DIR} --gpu-api=vulkan --loop --hwdec=auto --profile=high-quality --video-sync=display-resample --interpolation --tscale=oversample >/dev/null 2>&1" >/dev/null 2>&1
  #systemd-run --user --no-block bash -c "mpvpaper -o 'loop --no-audio --hwdec=auto --profile=high-quality --video-sync=display-resample --interpolation --tscale=oversample' '*' $DIR"
fi
