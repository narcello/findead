import fs from 'fs'
import { exec } from 'child_process'

describe('Findead', () => {
  it('first test', async () => {
    const script = 'ts-node ./findead.ts src'
    await exec(script, () => {
      expect(1+1).toEqual(2)
    })
  })
})