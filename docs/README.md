# :mag: findead

Dead react components finder

[![NPM Version](https://img.shields.io/npm/v/findead?logo=npm)]()
[![NPM Downloads](https://img.shields.io/npm/dw/findead?logo=npm)]()
![Tests](https://github.com/narcello/findead/workflows/TESTS/badge.svg)

## :dart: Motivation: _Dead Components_

Many times in large or even small projects, we forgot some components in code that we'll never use and we never take time to search one by one and remove.

## :camera: Demonstration

![Demonstration](https://user-images.githubusercontent.com/6786382/152322590-c2d40b74-f59c-4d05-97f2-08b4dde9481c.png)
When findead finish, you'll can see:

- Path of each one component
- Size of each one file
- How many dead components
- How many browsed files
- How much time spent to execution

## :computer: Tech

Made with node and typescript.

## :inbox_tray: Install

- Npm

```sh
npm i -g findead
```

- Yarn

```sh
yarn add findead
```

## :hammer: Usage

```bash
findead <folder_to_get_components>
```

Pass folder to get all of your components in js, jsx, ts and tsx files.

**_obs: By default, all `node_modules` folder is ignored._**

## :zap: Examples

#### Just one argument


```bash
findead ~/path/to/search
```

#### Multiple and specific folders

```bash
findead ~/path/to/search/{folder1,folder2,...,folderN}
```
