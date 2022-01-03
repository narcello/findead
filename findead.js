// read the path
// get all js, jsx, ts, tsx files in path
// searchFiles

// -> getComponents
// searchImports

const path = require("path");
const fs = require("fs");
const allFiles = [];

const regexFilesTypes = /(?<!chunk|min|stories|test|bundle)\.(js|ts|jsx|tsx)/;
const ignoredFolders = /(node_modules|dist|build|bin|out|output|target|log|logs|test|tests)/;

getFiles(process.argv[2]);
console.log(allFiles);

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
