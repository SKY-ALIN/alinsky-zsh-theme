#!/bin/zsh

if [[ -z "$ZSH_CUSTOM" ]]; then
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
fi

THEMES_DIR="$ZSH_CUSTOM/themes"

if [[ ! -d "$THEMES_DIR" ]]; then
    echo "Can't fine directory $THEMES_DIR"
    exit 1
fi

cp ./alinsky.zsh-theme "$THEMES_DIR/"

if [[ $? -eq 0 ]]; then
    echo "Theme installed into $THEMES_DIR"
else
    echo "Unexpected error"
    exit 1
fi

source "$HOME/.zshrc"
