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

current_dir="$(echo $PWD | sed 's/^.//')"
#command grep -ia "^$(printf $current_dir)" $HOME/Downloads/dirs-db 2>/dev/null > testfile
#current="$(command grep -ia "^$(printf $current_dir)" $HOME/Downloads/dirs-db 2>/dev/null)"
command grep -ia "^$(echo $current_dir)" $HOME/Downloads/dirs-db 2>/dev/null > /tmp/file1
command ag -i --hidden --ignore '.gitignore' --ignore-dir '.*git*' -g '' 2>/dev/null | sed "s@^@${PWD}/@" | sed 's/^\///' | sed 's#/[^/]*$##' | LC_ALL=c sort -u > /tmp/file2

awk '
NR==FNR {
    seen[$0]
    next
}
!($0 in seen) {              # if word is not hashed to seen
    seen[$0]                 # hash unseen a.txt words to seen to avoid duplicates 
    print                    # and output it
}' /tmp/file1 /tmp/file2 > /tmp/file3

if [ -e "/tmp/file1" ] && [ ! -s "/tmp/file1" ]; then
  print_success "NEW entries found!..."
  #awk -i inplace 'NR==FNR{a[$1]; next} !($NF in a)' /tmp/file1 $HOME/Downloads/dirs-db
  cat /tmp/file2 >> $HOME/Downloads/dirs-db
  LC_ALL=c sort -u -o $HOME/Downloads/dirs-db $HOME/Downloads/dirs-db
  rm -vf /tmp/file* &>/dev/null
  exit 0
fi

if cmp -s "/tmp/file1" "/tmp/file2"
then
  print_info "No new entries found..."
else
  print_updated "Up to date"
  awk -i inplace 'NR==FNR{a[$1]; next} !($NF in a)' /tmp/file1 $HOME/Downloads/dirs-db
  awk 'NR==FNR {seen[$0];next} !($0 in seen) { seen[$0];print }' $HOME/Downloads/dirs-db /tmp/file3 > /tmp/file4  
  cat /tmp/file2 >> /tmp/file4
  cat /tmp/file4 >> $HOME/Downloads/dirs-db
  LC_ALL=c sort -u -o $HOME/Downloads/dirs-db $HOME/Downloads/dirs-db
fi
rm -vf /tmp/file* &>/dev/null
