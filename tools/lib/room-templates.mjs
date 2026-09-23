import { readFileSync } from 'node:fs';

export const PORT_WEST = 0x01;
export const PORT_EAST = 0x02;
export const PORT_NORTH = 0x04;
export const PORT_SOUTH = 0x08;

const PORT_CELLS = new Map([
  [PORT_WEST, [[0, 5], [0, 6]]],
  [PORT_EAST, [[9, 5], [9, 6]]],
  [PORT_NORTH, [[4, 0], [5, 0], [6, 0]]],
  [PORT_SOUTH, [[4, 7], [5, 7], [6, 7]]],
]);

export function loadRoomTemplateSet(path) {
  return JSON.parse(readFileSync(path, 'utf8'));
}

export function validateRoomTemplateSet(set) {
  const errors = [];
  if (set.version !== 1) errors.push(`unsupported template format version ${set.version}`);
  if (set.roomWidth !== 10 || set.roomHeight !== 8) errors.push('room dimensions must be 10×8');
  if (JSON.stringify(set.legend) !== JSON.stringify({ '.': 'empty', '#': 'solid', '=': 'one_way' })) {
    errors.push('legend must define empty, solid, and one_way cells');
  }

  const ids = new Set();
  for (const template of set.templates ?? []) {
    const label = template.id ?? '<unnamed>';
    if (!template.id || ids.has(template.id)) errors.push(`${label}: template ID is missing or duplicated`);
    ids.add(template.id);
    if (!Number.isInteger(template.portMask) || template.portMask < 1 || template.portMask > 15) {
      errors.push(`${label}: port mask must be an integer from 1 through 15`);
    }
    if (!Array.isArray(template.rows) || template.rows.length !== set.roomHeight) {
      errors.push(`${label}: template must contain ${set.roomHeight} rows`);
      continue;
    }
    for (let y = 0; y < template.rows.length; y++) {
      const row = template.rows[y];
      if (row.length !== set.roomWidth) errors.push(`${label}: row ${y} must contain ${set.roomWidth} cells`);
      for (const cell of row) if (!(cell in set.legend)) errors.push(`${label}: row ${y} contains unknown cell '${cell}'`);
    }
    if (template.rows.some(row => row.length !== set.roomWidth)) continue;

    for (let y = 0; y < set.roomHeight; y++) {
      for (let x = 0; x < set.roomWidth; x++) {
        if (x !== 0 && x !== set.roomWidth - 1 && y !== 0 && y !== set.roomHeight - 1) continue;
        const open = [...PORT_CELLS].some(([port, cells]) =>
          template.portMask & port && cells.some(([portX, portY]) => portX === x && portY === y));
        const expected = open ? '.' : '#';
        if (template.rows[y][x] !== expected) errors.push(`${label}: boundary cell ${x},${y} must be '${expected}'`);
      }
    }

    for (let y = 0; y < set.roomHeight; y++) {
      for (let x = 0; x < set.roomWidth; x++) {
        if (template.rows[y][x] !== '=') continue;
        for (let ceilingY = y - 1; ceilingY >= 0; ceilingY--) {
          if (template.rows[ceilingY][x] !== '#') continue;
          if (y - ceilingY - 1 < 3) errors.push(`${label}: one-way cell ${x},${y} has less than three empty rows below a solid ceiling`);
          break;
        }
      }
    }
  }
  return errors;
}

export function templateSetToFixture(set) {
  const margin = 1;
  const spacing = 2;
  const width = margin * 2 + set.templates.length * set.roomWidth + (set.templates.length - 1) * spacing;
  const height = set.roomHeight + margin * 2;
  const cells = Array.from({ length: height }, () => Array(width).fill('.'));
  const placements = [];

  for (let index = 0; index < set.templates.length; index++) {
    const template = set.templates[index];
    const originX = margin + index * (set.roomWidth + spacing);
    const originY = margin;
    placements.push({ template, originX, originY });
    for (let y = 0; y < set.roomHeight; y++) {
      for (let x = 0; x < set.roomWidth; x++) cells[originY + y][originX + x] = template.rows[y][x];
    }
  }

  return { width, height, placements, tiles: semanticCellsToTileIds(cells) };
}

export function semanticCellsToTileIds(cells) {
  const height = cells.length;
  const width = cells[0].length;
  return cells.map((row, y) => row.map((cell, x) => {
    if (cell === '.') return 17;
    if (cell === '=') return 50;
    const neighborMask =
      (y > 0 && cells[y - 1][x] === '#' ? 1 : 0) |
      (x < width - 1 && cells[y][x + 1] === '#' ? 2 : 0) |
      (y < height - 1 && cells[y + 1][x] === '#' ? 4 : 0) |
      (x > 0 && cells[y][x - 1] === '#' ? 8 : 0);
    return 1 + neighborMask;
  }));
}
