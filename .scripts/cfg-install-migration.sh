#!/usr/bin/env bash

echo ".cfg" >>$HOME/.gitignore

function config {
  /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

dotfiles_init() {
  git --no-replace-objects clone --bare --depth 1 \
    git@github.com:jazzsakura/dotfiles.git $HOME/.cfg
  config config --local status.showUntrackedFiles no
  config checkout -f
}

#config remote add origin git@github.com:jazzsakura/dotfiles.git
#config remote set-url origin git@github.com:jazzsakura/dotfiles.git
#config push -u origin master
