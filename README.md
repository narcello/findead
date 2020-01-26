# :mag: findead
Dead react components finder


[![NPM Version](https://img.shields.io/npm/v/findead?logo=npm)]()
[![NPM Downloads](https://img.shields.io/npm/dw/findead?logo=npm)]()
![Tests](https://github.com/narcello/findead/workflows/TESTS/badge.svg)

## :dart: Motivation: *Dead Components*
Many times in large or even small projects, we forgot some components in code that we'll never use and we never take time to search one by one and remove.

## :camera: Demonstration
![](https://media.giphy.com/media/iFfljysdC7VDyuFh4r/giphy.gif)

## :computer: Tech
Just bash :) 

## :inbox_tray: Install
* Npm
```sh 
npm i -g findead
```
* Yarn
```sh 
yarn add findead
```

## :hammer: Usage
```bash
findead <folder_to_get_components> <folder_to_find_usages>
```
1. First, pass folder to get all of your components
2. Pass folder to search usages

## :zap: Examples
#### With two arguments
```bash
findead ~/path/to/get/components ~/path/to/search/usages
```
#### Just one argument 
* If you pass just one argument, it will be used for `get components` and `search usages`
```bash
findead ~/path/to/get/components
```
#### Get components in multiple folders
 ```bash
findead ~/path/to/get/components/{folder1,folder2,...,folderN} ~/path/to/search/usages
```
