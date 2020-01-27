#!/usr/bin/env sh

set -e

cp docs/README.md README.md

npm publish

rm README.md