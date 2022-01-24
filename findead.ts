import path from 'path';
import fs from 'fs';

const allFiles: string[] = [];
const unusedFiles: string[] = [];

const regexFilesTypes = /(?<!chunk|min|stories|test|bundle|setup)\.(js|ts|jsx|tsx)/;
const ignoredFolders = /(node_modules|dist|build|bin|out|output|coverage|target|log|logs|test|tests|.storybook)/;

function constructEs6ImportRegExp(baseName: string) {
  return new RegExp(`(.*)import.*from (\\"|\\')(.*)${baseName}(\\"|\\')`, 'g');
}

function constructEs5ImportRegExp(baseName: string) {
  return new RegExp(`(.*)require\\((\\"|\\')(.*)${baseName}(\\"|\\')\\)`, 'g');
}

function constructLazyLoadImportRegExp(baseName: string) {
  return new RegExp(`(.*)import\\((\\"|\\')(.*)${baseName}(\\"|\\')\\)`, 'g');
}

function singleLineCommentRegExp() {
  return /\/\/.*/g;
}

function multiLineCommentRegExp() {
  return /\/\*[\s\S]*\*\//g;
}

function removeComments(data: string) {
  return data
    .replace(multiLineCommentRegExp(), '')
    .replace(singleLineCommentRegExp(), '');
}

function getFiles(startPath: string) {
  if (!fs.existsSync(startPath)) {
    console.log('no dir ', startPath);
    return;
  }

  const files = fs.readdirSync(startPath);

  for (let i = 0; i < files.length; i += 1) {
    const filename = path.join(startPath, files[i]);
    const stat = fs.lstatSync(filename);

    if (stat.isDirectory()) {
      if (!ignoredFolders.test(filename)) getFiles(filename);
    } else if (regexFilesTypes.test(filename)) {
      allFiles.push(filename);
    }
  }
}

function thereIsIndexFile(directoryPath: string) {
  const files = fs.readdirSync(directoryPath);
  const hasIndexFile = files.some((file: string) => file.indexOf('index') > -1);
  return hasIndexFile;
}

function thereIsExportOnFile(filePath: string) {
  const data = fs.readFileSync(filePath, 'utf8');
  return data.indexOf('export') > -1;
}

function searchImports(filesPath: string[]) {
  filesPath.forEach((filePath, _index, array) => {
    if(!thereIsExportOnFile(filePath)) return;

    let baseName = path.basename(filePath);
    baseName = baseName.replace(path.extname(filePath), '');

    const fileFolder = path.dirname(filePath);
    const hasIndexFile = thereIsIndexFile(fileFolder);
    if (hasIndexFile) baseName = path.basename(fileFolder);

    const es6ImportRegExp = constructEs6ImportRegExp(baseName);
    const es5ImportRegExp = constructEs5ImportRegExp(baseName);
    const lazyLoadImportRegExp = constructLazyLoadImportRegExp(baseName);

    const isUsedFile = array.some((file) => {
      try {
        const data = fs.readFileSync(file, 'utf8');

        const dataWithoutComments = removeComments(data);

        return (
          es6ImportRegExp.test(dataWithoutComments)
          || es5ImportRegExp.test(dataWithoutComments)
          || lazyLoadImportRegExp.test(dataWithoutComments)
        );
      } catch (err) {
        return false;
      }
    });

    if (!isUsedFile) unusedFiles.push(filePath);
  });
}

function showResult() {
  if(unusedFiles.length > 0) 
    console.log(unusedFiles)
  else console.log('No unused files :)')
}

function startFindead() {
  console.time();
  getFiles(process.argv[2]);
  searchImports(allFiles);
  showResult();
  console.timeEnd();
}

startFindead();