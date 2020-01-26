#!/usr/bin/env sh

git config --global user.email "marcellovcs@gmail.com"
git config --global user.name "narcello"

set -e

npm run site:build

cd docs/.vuepress/dist

git init
git add -A
git commit -m 'deploy'

git push -f git@github.com:narcello/findead.git master:gh-pages

cd -
