Adicionar eslint - ok
Tentar passar para typescript - ok
Adicionar o husky(pre-commit - test e commit lint msg) - ok
Atualizar os testes - ok
Atualizar eslint com ts - ok
add format on save
Atualizar readme
Analizar o código e ver o fluxo
Anotar possíveis melhorias
Remover tudo do antigo
  findead.sh
  index.bats
  dependencies

# :mag: findead

Dead react components finder

[![NPM Version](https://img.shields.io/npm/v/findead?logo=npm)]()
[![NPM Downloads](https://img.shields.io/npm/dw/findead?logo=npm)]()
![Tests](https://github.com/narcello/findead/workflows/TESTS/badge.svg)

## :dart: Motivation: _Dead Components_

Many times in large or even small projects, we forgot some components in code that we'll never use and we never take time to search one by one and remove.

## :camera: Demonstration

![Demonstration](https://user-images.githubusercontent.com/6786382/73863397-c3d5aa00-481e-11ea-9360-0a530a93cd4a.png)
When findead finish, you'll can see:

- Components name
- Path of each one component
- Size of each one file
- How many dead components
- How many browsed files
- How much time spent to execution

## :computer: Tech

Just bash :)

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

- If you pass just one argument, it will be used for `get components` and `search usages`

```bash
findead ~/path/to/search
```

#### Raw result

- Pass `-r` flag for raw output. Better for atribute output into a file.

```bash
findead -r ~/path/to/search
```

#### Multiple and specific folders

```bash
findead -m ~/path/to/search/{folder1,folder2,...,folderN}
```
