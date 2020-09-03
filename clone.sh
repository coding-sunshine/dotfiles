#!/bin/sh

# git global settings
git config --global pull.rebase true
git config --global user.email "sunshine.mahant@gmail.com"
git config --global user.name "Sunshine"

echo "Cloning repositories..."

SITES=$HOME/Code
CODEASEA=$SITES/Codeasea
AECOR=$SITES/Aecor
ZERO=$SITES/Zero
PERSONAL=$SITES/Personal
EXPERIMENTS=$SITES/Experiments

# Personal
#git clone git@github.com:driesvints/checklists.git $SITES/checklists

# Laravel
#git clone git@github.com:laravel/ui.git $LARAVEL/ui
