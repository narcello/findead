const path = require("path");
const fs = require("fs");
const allFiles = [];
const unusedFiles = [];

const regexFilesTypes = /(?<!chunk|min|stories|test|bundle|setup)\.(js|ts|jsx|tsx)/;
const ignoredFolders = /(node_modules|dist|build|bin|out|output|coverage|target|log|logs|test|tests|.storybook)/;

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

function thereIsIndexFile(directoryPath) {
  const files = fs.readdirSync(directoryPath);
  const hasIndexFile = files.some((file) => file.indexOf("index") > -1);
  return hasIndexFile;
}

function searchImports(filesPath) {
  filesPath.forEach((filePath, index, array) => {
    let baseName = path.basename(filePath);
    baseName = baseName.replace(path.extname(filePath), "");

    const fileFolder = path.dirname(filePath);
    const hasIndexFile = thereIsIndexFile(fileFolder);
    if (hasIndexFile) baseName = path.basename(fileFolder);

    const es6ImportRegExp = constructEs6ImportRegExp(baseName);
    const es5ImportRegExp = constructEs5ImportRegExp(baseName);
    const lazyLoadImportRegExp = constructLazyLoadImportRegExp(baseName);

    const isUsedFile = array.some((file) => {
      try {
        const data = fs.readFileSync(file, "utf8");

        const dataWithoutComments = removeComments(data);

        return (
          es6ImportRegExp.test(dataWithoutComments) ||
          es5ImportRegExp.test(dataWithoutComments) ||
          lazyLoadImportRegExp.test(dataWithoutComments)
        );
      } catch (err) {
        console.error(err);
      }
    });
    if (!isUsedFile) unusedFiles.push(filePath);
  });
}

function constructEs6ImportRegExp(baseName) {
  return new RegExp(`(.*)import.*from (\\"|\\')(.*)${baseName}(\\"|\\')`, "g");
}

function constructEs5ImportRegExp(baseName) {
  return new RegExp(`(.*)require\\((\\"|\\')(.*)${baseName}(\\"|\\')\\)`, "g");
}

function constructLazyLoadImportRegExp(baseName) {
  return new RegExp(`(.*)import\\((\\"|\\')(.*)${baseName}(\\"|\\')\\)`, "g");
}

function singleLineCommentRegExp() {
  return new RegExp("//.*", "g");
}

function multiLineCommentRegExp() {
  return new RegExp("\\/\\*[\\s\\S]*\\*\\/", "g");
}

function removeComments(data) {
  return data
    .replace(multiLineCommentRegExp(), "")
    .replace(singleLineCommentRegExp(), "");
}
