import { exec } from 'child_process'
jest.useFakeTimers('legacy')

describe('Findead', () => {
  it('first test', (done) => {
    const script = 'ts-node ./findead.ts src/components'
    exec(script, (error, stdout, stderr) => {
      console.log(stdout);
      if(error || stderr) done();
      expect(stdout.indexOf('src/imports/inde2.js')).toBeGreaterThan(-1)
      done()
    });
  })
})