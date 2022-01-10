const path = require("path");
const fs = require("fs");
const allFiles = [];
const unusedFiles = [];

const regexFilesTypes = /(?<!chunk|min|stories|test|bundle|setup)\.(js|ts|jsx|tsx)/;
const ignoredFolders = /(node_modules|dist|build|bin|out|output|coverage|target|log|logs|test|tests|.storybook)/;

getFiles(process.argv[2]);
searchImports(allFiles);
// console.log(unusedFiles);

function getFiles(startPath) {
  if (!fs.existsSync(startPath)) {
    console.log("no dir ", startPath);
    return;
  }

  const files = fs.readdirSync(startPath);

  for (var i = 0; i < files.length; i++) {
    const filename = path.join(startPath, files[i]);
    const stat = fs.lstatSync(filename);

    if (stat.isDirectory()) {
      if (!ignoredFolders.test(filename)) getFiles(filename);
    } else if (regexFilesTypes.test(filename)) {
      allFiles.push(filename);
    }
  }
}

// Arquivos com nome 'index' nao precisam ser verificado se tem import
// deverá ser prcurado pelo import do nome do folder
// verificar comentarios

// pastas que contem o arquivo index podem ser importadas em outros aquivos index

// como ver se um component está sendo usado
// itens para se verificar
// tipo do export
// se tem index na pasta
// tipo do import

// Entender como ele foi exportado -> verificar se ele ta passando por index files -> procurar por usos ou imports(lazy load)
// Procurar se o que foi exportado está sendo usado em algum lugar.
function thereIsIndexFile(directoryPath) {
  let thereIsIndexFile = false;
  fs.readdir(directoryPath, (err, files) => {
    if (err) {
      return console.log("Unable to scan directory: " + err);
    }
    thereIsIndexFile = files.some((file) => file.indexOf("index") > -1);
  });
  return thereIsIndexFile;
}

function searchImports(filesPath) {
  filesPath.forEach((filePath, index, array) => {
    let baseName = path.basename(filePath);
    baseName = baseName.replace(path.extname(filePath), "");

    // a pasta tem index?
    const fileFolder = path.dirname(filePath);
    if (thereIsIndexFile(fileFolder)) console.log(fileFolder);

    // se sim, tenho que procurar pelo import do nome da pasta.

    const es6ImportRegExp = constructEs6ImportRegExp(baseName);
    const es5ImportRegExp = constructEs5ImportRegExp(baseName);
    const lazyLoadImportRegExp = constructLazyLoadImportRegExp(baseName);

    const isUsedFile = array.some((file) => {
      try {
        const data = fs.readFileSync(file, "utf8");
        return (
          es6ImportRegExp.test(data) ||
          es5ImportRegExp.test(data) ||
          lazyLoadImportRegExp.test(data)
        );
      } catch (err) {
        console.error(err);
      }
    });
    if (!isUsedFile) unusedFiles.push(filePath);
  });
}

function constructEs6ImportRegExp(baseName) {
  return new RegExp(`import.*from (\\"|\\')(.*)${baseName}(\\"|\\')`, "gm");
}

function constructEs5ImportRegExp(baseName) {
  return new RegExp(`require\\((\\"|\\')(.*)${baseName}(\\"|\\')\\)`, "gm");
}

function constructLazyLoadImportRegExp(baseName) {
  return new RegExp(`import\\((\\"|\\')(.*)${baseName}(\\"|\\')\\)`, "gm");
}
