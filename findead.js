const path = require("path");
const fs = require("fs");
const allFiles = [];
const unusedFiles = [];

const regexFilesTypes = /(?<!chunk|min|stories|test|bundle)\.(js|ts|jsx|tsx)/;
const ignoredFolders = /(node_modules|dist|build|bin|out|output|target|log|logs|test|tests)/;

getFiles(process.argv[2]);
searchImports(allFiles);
console.log(unusedFiles);

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

function searchImports(filesNames) {
  filesNames.forEach((fileName, index, array) => {
    let baseName = path.basename(fileName);
    baseName = baseName.replace(path.extname(fileName), "");

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
    if (!isUsedFile) unusedFiles.push(fileName);
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
