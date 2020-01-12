# findead
Dead react components finder

## How install
* Npm
```sh 
npm i -g findead
```

## Usage
```bash
findead <folder_to_get_components> <folder_to_find_usages>
```
1. First, pass folder to get all of your components
2. Pass folder to search usages

## Examples
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

#### Obs
* Today `findead` module just work's with class components