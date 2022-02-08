import { exec } from 'child_process';

describe('Findead', () => {
  it('Should validate used component', (done) => {
    const script = 'ts-node ./findead.ts src';
    exec(script, (error, stdout, stderr) => {
      done();
      if (error || stderr) console.error(error, stderr);
      expect(stdout).toContain('No unused components');
    });
  });

  it('Should validate unused component(without imports)', (done) => {
    const script = 'ts-node ./findead.ts src/components';
    exec(script, (error, stdout, stderr) => {
      done();
      if (error || stderr) console.error(error, stderr);
      expect(stdout).toContain('16 unused components');
    });
  });

  it('Should validate unused component(commented imports)', (done) => {
    const script = 'ts-node ./findead.ts src/components src/1.imports_commented';
    exec(script, (error, stdout, stderr) => {
      done();
      if (error || stderr) console.error(error, stderr);
      expect(stdout).toContain('16 unused components');
    });
  });

  it.skip('Should validate unused component(commented imports)', (done) => {
    const script = 'ts-node ./findead.ts src/{components,1.imports_commented}';
    exec(script, (error, stdout, stderr) => {
      done();
      if (error || stderr) console.error(error, stderr);
      expect(stdout).toContain('16 unused components');
    });
  });

  it('Should validate error: no arguments', (done) => {
    const script = 'ts-node ./findead.ts';
    exec(script, (error, stdout, stderr) => {
      done();
      if (error || stderr) console.error(error, stderr);
      expect(stdout).toContain('No arguments');
    });
  });

  it('Should validate --version predicate', (done) => {
    const script = 'ts-node ./findead.ts --version';
    exec(script, (error, stdout, stderr) => {
      done();
      if (error || stderr) console.error(error, stderr);
      expect(stdout).toContain('2.0.0-alfa');
    });
  });

  it('Should validate -v predicate', (done) => {
    const script = 'ts-node ./findead.ts -v';
    exec(script, (error, stdout, stderr) => {
      done();
      if (error || stderr) console.error(error, stderr);
      expect(stdout).toContain('2.0.0-alfa');
    });
  });

  it('Should validate --help predicate', (done) => {
    const script = 'ts-node ./findead.ts -h';
    exec(script, (error, stdout, stderr) => {
      done();
      if (error || stderr) console.error(error, stderr);

      expect(stdout).toContain('usage');
      expect(stdout).toContain('findead path/to/search');

      expect(stdout).toContain('multiple folders');
      expect(stdout).toContain('findead path/to/{folderA,folderB}');

      expect(stdout).toContain('-v');
      expect(stdout).toContain('--version');
      expect(stdout).toContain('Get the findead version');

      expect(stdout).toContain('-h');
      expect(stdout).toContain('--help');
      expect(stdout).toContain('Get the findead help');
    });
  });

  it('Should validate -h predicate', (done) => {
    const script = 'ts-node ./findead.ts -h';
    exec(script, (error, stdout, stderr) => {
      done();
      if (error || stderr) console.error(error, stderr);

      expect(stdout).toContain('usage');
      expect(stdout).toContain('findead path/to/search');

      expect(stdout).toContain('multiple folders');
      expect(stdout).toContain('findead path/to/{folderA,folderB}');

      expect(stdout).toContain('-v');
      expect(stdout).toContain('--version');
      expect(stdout).toContain('Get the findead version');

      expect(stdout).toContain('-h');
      expect(stdout).toContain('--help');
      expect(stdout).toContain('Get the findead help');
    });
  });

  it('Should validate ignored type files', (done) => {
    const script = 'ts-node ./findead.ts src/ignored_types';
    exec(script, (error, stdout, stderr) => {
      done();
      if (error || stderr) console.error(error, stderr);
      expect(stdout).toContain('No unused components');
    });
  });

  it('Should validate ignored paths', (done) => {
    const script = 'ts-node ./findead.ts src/ignored_paths';
    exec(script, (error, stdout, stderr) => {
      done();
      if (error || stderr) console.error(error, stderr);
      expect(stdout).toContain('No unused components');
    });
  });
});
