#!/usr/bin/env sh

set -e

npm run site:build

cd docs/.vuepress/dist

git config user.email "marcellovcs@gmail.com"
git config user.name "narcello"

git init
git add -A
git commit -m 'deploy'

git push -f git@github.com:narcello/findead.git master:gh-pages

cd -
