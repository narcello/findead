import { exec } from 'child_process'

describe('Findead', () => {
  it('Should validate used component', (done) => {
    const script = 'ts-node ./findead.ts src';
    exec(script, (error, stdout, stderr) => {
      done();
      if(error || stderr) done();
      expect(stdout.indexOf('No unused components')).toBeGreaterThan(-1);
    });
  });
  
  it('Should validate unused component(without imports)', (done) => {
    const script = 'ts-node ./findead.ts src/components';
    exec(script, (error, stdout, stderr) => {
      done();
      if(error || stderr) done();
      expect(stdout.indexOf('16 unused components')).toBeGreaterThan(-1);
    });
  });
  
  it('Should validate unused component(commented imports)', (done) => {
    const script = 'ts-node ./findead.ts src/components src/1.imports_commented'
    exec(script, (error, stdout, stderr) => {
      done();
      if(error || stderr) done();
      expect(stdout.indexOf('16 unused components')).toBeGreaterThan(-1);
    });
  });
  
  it.skip('Should validate error: paths must precede expression', (done) => {
    const script = 'ts-node ./findead.ts src/components'
  });
  
  it.skip('Should validate --version predicate', (done) => {
    const script = 'ts-node ./findead.ts src/components'
  });
  
  it.skip('Should validate -v predicate', (done) => {
    const script = 'ts-node ./findead.ts src/components'
  });
  
  it.skip('Should validate --help predicate', (done) => {
    const script = 'ts-node ./findead.ts src/components'
  });
  
  it.skip('Should validate -h predicate', (done) => {
    const script = 'ts-node ./findead.ts src/components'
  });
  
  it.skip('Should validate -r predicate', (done) => {
    const script = 'ts-node ./findead.ts src/components'
  });
  
  it.skip('Should validate multiples predicate', (done) => {
    const script = 'ts-node ./findead.ts src/components'
  });
  
  it.skip('Should validate ignored type files', (done) => {
    const script = 'ts-node ./findead.ts src/components'
  });
  
  it.skip('Should validate ignored paths', (done) => {
    const script = 'ts-node ./findead.ts src/components'
  });
})