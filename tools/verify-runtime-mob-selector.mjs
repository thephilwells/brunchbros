import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const symbols = new Map(readFileSync('build/main.sym', 'utf8').split('\n').flatMap(line => {
  const match = line.match(/^([\da-f]+):([\da-f]+) (\S+)$/i);
  return match ? [[match[3], { bank: parseInt(match[1], 16), address: parseInt(match[2], 16) }]] : [];
}));
const rom = readFileSync('build/brunchbros.gb');
const symbol = name => {
  assert(symbols.has(name), `Missing symbol ${name}`);
  return symbols.get(name);
};
const memoryAddress = name => symbol(name).address;
const romOffset = name => {
  const { bank, address } = symbol(name);
  return bank ? bank * 0x4000 + address - 0x4000 : address;
};
const mixSelection = (seed, room, salt) => {
  let state = ((seed || 0xace1) ^ ((room + 1) * 0x9e37) ^ salt) & 0xffff;
  state = (state ^ state << 7) & 0xffff;
  state = (state ^ state >>> 9) & 0xffff;
  return (state ^ state << 8) & 0xffff;
};

function selectRoom(counts, seed = 1, salt = 44257) {
  const memory = new Uint8Array(0x10000);
  memory.set(counts, memoryAddress('MobCandidateCounts'));
  let pc = romOffset('FindBestMobRoom');
  let a = 0;
  let b = 0;
  let d = 0;
  let e = 0;
  let hl = 0;
  let zero = false;
  let carry = false;
  const next = () => rom[pc++];
  const word = () => next() | next() << 8;
  const branch = condition => {
    const displacement = next();
    if (condition) pc += displacement < 128 ? displacement : displacement - 256;
  };
  for (let steps = 0; steps < 10000; steps++) {
    switch (next()) {
      case 0xaf: a = 0; zero = true; carry = false; break;
      case 0xea: memory[word()] = a; break;
      case 0xfa: a = memory[word()]; break;
      case 0x5f: e = a; break;
      case 0x16: d = next(); break;
      case 0x21: hl = word(); break;
      case 0x19: {
        const result = hl + (d << 8 | e);
        hl = result & 0xffff;
        carry = result > 0xffff;
        break;
      }
      case 0x7e: a = memory[hl]; break;
      case 0x28: branch(zero); break;
      case 0x20: branch(!zero); break;
      case 0x38: branch(carry); break;
      case 0x18: branch(true); break;
      case 0xa7: zero = a === 0; carry = false; break;
      case 0x47: b = a; break;
      case 0xb8: zero = a === b; carry = a < b; break;
      case 0xfe: {
        const value = next();
        zero = a === value;
        carry = a < value;
        break;
      }
      case 0x3e: a = next(); break;
      case 0x3c: a = (a + 1) & 0xff; zero = a === 0; break;
      case 0xcd: {
        const target = word();
        if (target === memoryAddress('LoadMobSelectionSalt')) break;
        assert.equal(target, memoryAddress('MobSelectionMix'));
        const score = mixSelection(seed, a, salt);
        memory[memoryAddress('MobMixResult')] = score & 0xff;
        memory[memoryAddress('MobMixResult') + 1] = score >> 8;
        break;
      }
      case 0xc9:
        return {
          found: memory[memoryAddress('MobBestFound')],
          room: memory[memoryAddress('MobBestRoom')],
        };
      default:
        throw new Error(`Unsupported selector opcode at ROM offset ${(pc - 1).toString(16)}`);
    }
  }
  throw new Error('Selector instruction limit reached');
}

const onlyRoomZero = [1, ...Array(15).fill(0)];
const onlyRoomOne = [0, 1, ...Array(14).fill(0)];
assert.deepEqual(selectRoom(onlyRoomZero), { found: 1, room: 0 });
assert.deepEqual(selectRoom(onlyRoomOne), { found: 1, room: 1 });
assert.deepEqual(selectRoom(Array(16).fill(0)), { found: 0, room: 0 });

for (let seed = 0; seed < 0x100; seed++) {
  const counts = Array.from({ length: 16 }, (_, room) => (seed * 29 + room * 17) % 5 ? (seed + room) % 8 + 1 : 0);
  const selected = selectRoom(counts, seed);
  if (selected.found) assert.notEqual(counts[selected.room], 0, `Seed ${seed} selected empty room ${selected.room}`);
}

console.log('Compiled runtime mob selector rejects zero-candidate rooms.');
