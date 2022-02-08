import path from 'path';
import fs from 'fs';

const { log } = console;

const allFiles: string[] = [];
const unusedFiles: string[] = [];

const regexFilesTypes = /(?<!chunk|min|stories|test|bundle|setup)\.(js|ts|jsx|tsx)/;
const ignoredFolders = /(node_modules|dist|build|bin|out|output|coverage|target|log|logs|test|tests|.storybook|__generated__)/;

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
    log('no dir ', startPath);
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
    if (!thereIsExportOnFile(filePath)) return;

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

function getFileSize(filepath: string) {
  const stat = fs.lstatSync(filepath);
  return stat.size;
}

function formatFileSize(fileSize: number) {
  let result;
  if (fileSize <= 1023) { result = `${fileSize} bytes`; } else result = `${(fileSize / 1024).toFixed(2)} KB`;
  return `\x1b[33m${result}\x1b[0m`;
}

function showResult() {
  if (unusedFiles.length > 0) {
    unusedFiles.forEach((file) => {
      log('\x1b[36m%s\x1b[0m', file, '-', formatFileSize(getFileSize(file)));
    });
    log('\n');
    log(`${unusedFiles.length} unused components 😓`);
  } else log('No unused components 🎉');
  log(`${allFiles.length} browsed files`);
}

const help = {
  usage: 'findead path/to/search',
  'multiple folders': 'findead path/to/{folderA,folderB}',
  '-v': 'Get the findead version',
  '--version': 'Get the findead version',
  '-h': 'Get the findead help',
  '--help': 'Get the findead help',
};

function startFindead() {
  const flagPositionArg = process.argv[2];
  if (!flagPositionArg) {
    log('No arguments');
    return;
  }
  if (flagPositionArg === '-v' || flagPositionArg === '--version') {
    log('2.0.0-alfa');
  } else if (flagPositionArg === '-h' || flagPositionArg === '--help') {
    console.table(help);
  } else {
    console.time();
    console.clear();
    log('\x1b[33m%s\x1b[0m', 'Findead is looking for components...');
    log('\n');
    process.argv.splice(0, 2);
    process.argv.forEach(getFiles);
    searchImports(allFiles);
    showResult();
    console.timeEnd();
  }
}

startFindead();
