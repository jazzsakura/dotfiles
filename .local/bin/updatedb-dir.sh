#!/usr/bin/env bash

output(){
    printf "\e[1;34m%-6s\e[m\n" "${@}"
}

current_dir="$(echo $PWD | sed 's/^.//')"
#command grep -ia "^$(printf $current_dir)" $HOME/Downloads/bulk-tmp-dir 2>/dev/null > testfile
#current="$(command grep -ia "^$(printf $current_dir)" $HOME/Downloads/bulk-tmp-dir 2>/dev/null)"
command grep -ia "^$(printf $current_dir)" $HOME/Downloads/bulk-tmp-dir 2>/dev/null > file1
#new="$(command ag -i --hidden --ignore '.gitignore' --ignore-dir '.*git*' -g '' 2>/dev/null | sed "s@^@${PWD}/@" | sed 's/^\///' | sed 's#/[^/]*$##' | LC_ALL=c sort -u)"
command ag -i --hidden --ignore '.gitignore' --ignore-dir '.*git*' -g '' 2>/dev/null | sed "s@^@${PWD}/@" | sed 's/^\///' | sed 's#/[^/]*$##' | LC_ALL=c sort -u > file2

if [ -e "file1" ] && [ ! -s "file1" ]; then
  output "News entries found"
  cat file2 >> $HOME/Downloads/bulk-tmp-dir
  LC_ALL=c sort -o $HOME/Downloads/bulk-tmp-dir $HOME/Downloads/bulk-tmp-dir
  exit 0
fi

awk '
NR==FNR {
    seen[$0]
    next
}
!($0 in seen) {              # if word is not hashed to seen
    seen[$0]                 # hash unseen a.txt words to seen to avoid duplicates 
    print                    # and output it
}' file1 file2 &>/dev/null

if cmp -s "file1" "file2"
then
  output "No new entries found"
else
  output "Up to date"
  awk -i inplace 'NR==FNR{a[$1]; next} !($NF in a)' file1 $HOME/Downloads/bulk-tmp-dir
  cat file2 >> $HOME/Downloads/bulk-tmp-dir
  LC_ALL=c sort -o $HOME/Downloads/bulk-tmp-dir $HOME/Downloads/bulk-tmp-dir
fi
rm -vf file* &>/dev/null
