export const GRID_WIDTH = 4;
export const GRID_HEIGHT = 4;
export const ROOM_WIDTH = 10;
export const ROOM_HEIGHT = 8;
export const LEVEL_WIDTH = GRID_WIDTH * ROOM_WIDTH;
export const LEVEL_HEIGHT = GRID_HEIGHT * ROOM_HEIGHT;

export const PORT_WEST = 0x01;
export const PORT_EAST = 0x02;
export const PORT_NORTH = 0x04;
export const PORT_SOUTH = 0x08;

const PORT_ORDINAL = new Map([
  [0, 0],
  [PORT_WEST, 1],
  [PORT_EAST, 2],
  [PORT_NORTH, 3],
  [PORT_SOUTH, 4],
]);

function nextRandom(state) {
  state = (state ^ (state << 7)) & 0xffff;
  state = (state ^ (state >>> 9)) & 0xffff;
  return (state ^ (state << 8)) & 0xffff;
}

export function routeFromColumns(columns, seed = null, randomState = 0xace1) {
  if (columns.length !== 5 || columns.some(column => !Number.isInteger(column) || column < 0 || column >= GRID_WIDTH)) {
    throw new Error('Route columns must contain five values from 0 through 3');
  }

  const criticalRoute = [columns[0]];
  let column = columns[0];

  for (let row = 0; row < GRID_HEIGHT - 1; row++) {
    const target = columns[row + 1];
    const direction = Math.sign(target - column);
    while (column !== target) {
      column += direction;
      criticalRoute.push(row * GRID_WIDTH + column);
    }
    criticalRoute.push((row + 1) * GRID_WIDTH + column);
  }

  const exitColumn = columns[4];
  const direction = Math.sign(exitColumn - column);
  while (column !== exitColumn) {
    column += direction;
    criticalRoute.push((GRID_HEIGHT - 1) * GRID_WIDTH + column);
  }

  const roomPorts = Array(GRID_WIDTH * GRID_HEIGHT).fill(0);
  for (let index = 1; index < criticalRoute.length; index++) {
    const from = criticalRoute[index - 1];
    const to = criticalRoute[index];
    const delta = to - from;
    if (delta === 1) {
      roomPorts[from] |= PORT_EAST;
      roomPorts[to] |= PORT_WEST;
    } else if (delta === -1) {
      roomPorts[from] |= PORT_WEST;
      roomPorts[to] |= PORT_EAST;
    } else if (delta === GRID_WIDTH) {
      roomPorts[from] |= PORT_SOUTH;
      roomPorts[to] |= PORT_NORTH;
    } else {
      throw new Error(`Non-adjacent route rooms ${from} and ${to}`);
    }
  }

  const branchResult = connectRemainingRooms(roomPorts, criticalRoute, randomState);

  const roomTemplates = Array(GRID_WIDTH * GRID_HEIGHT).fill(0);
  for (let index = 0; index < criticalRoute.length; index++) {
    const room = criticalRoute[index];
    const entry = index === 0 ? 0 : portFromRoomToRoom(room, criticalRoute[index - 1]);
    const exit = index === criticalRoute.length - 1 ? 0 : portFromRoomToRoom(room, criticalRoute[index + 1]);
    roomTemplates[room] = 1 + PORT_ORDINAL.get(entry) * 5 + PORT_ORDINAL.get(exit);
  }

  const level = {
    version: 1,
    seed,
    columns: [...columns],
    criticalRouteLength: criticalRoute.length,
    criticalRoute,
    criticalRouteStorage: [...criticalRoute, ...Array(16 - criticalRoute.length).fill(0xff)],
    roomPorts,
    branchEdges: branchResult.edges,
    roomTemplates,
    spawnRoom: criticalRoute[0],
    exitRoom: criticalRoute.at(-1),
    finalRandomState: branchResult.randomState,
  };
  level.tiles = buildConnectivityScaffold(level);
  level.validation = validateLevel(level);
  return level;
}

export function generateLevel(seed) {
  if (!Number.isInteger(seed) || seed < 0 || seed > 0xffff) throw new Error('Seed must be an integer from 0 through 65535');
  let state = seed === 0 ? 0xace1 : seed;
  const columns = [];
  for (let index = 0; index < 5; index++) {
    state = nextRandom(state);
    columns.push(state & 3);
  }
  return routeFromColumns(columns, seed, state);
}

function connectRemainingRooms(roomPorts, criticalRoute, randomState) {
  const connected = new Set(criticalRoute);
  const edges = [];

  while (connected.size < GRID_WIDTH * GRID_HEIGHT) {
    const frontier = [];
    for (const room of connected) {
      const row = Math.floor(room / GRID_WIDTH);
      const column = room % GRID_WIDTH;
      if (column > 0 && !connected.has(room - 1)) frontier.push([room, room - 1]);
      if (column < GRID_WIDTH - 1 && !connected.has(room + 1)) frontier.push([room, room + 1]);
      if (row > 0 && !connected.has(room - GRID_WIDTH)) frontier.push([room, room - GRID_WIDTH]);
      if (row < GRID_HEIGHT - 1 && !connected.has(room + GRID_WIDTH)) frontier.push([room, room + GRID_WIDTH]);
    }

    randomState = nextRandom(randomState);
    const edge = frontier[randomState % frontier.length];
    const [from, to] = edge;
    roomPorts[from] |= portFromRoomToRoom(from, to);
    roomPorts[to] |= portFromRoomToRoom(to, from);
    connected.add(to);
    edges.push(edge);
  }

  return { edges, randomState };
}

function portFromRoomToRoom(from, to) {
  const delta = to - from;
  if (delta === -1) return PORT_WEST;
  if (delta === 1) return PORT_EAST;
  if (delta === -GRID_WIDTH) return PORT_NORTH;
  if (delta === GRID_WIDTH) return PORT_SOUTH;
  throw new Error(`Rooms ${from} and ${to} are not adjacent`);
}

function buildConnectivityScaffold(level) {
  const solid = Array.from({ length: LEVEL_HEIGHT }, () => Array(LEVEL_WIDTH).fill(false));

  for (let room = 0; room < GRID_WIDTH * GRID_HEIGHT; room++) {
    const roomX = (room % GRID_WIDTH) * ROOM_WIDTH;
    const roomY = Math.floor(room / GRID_WIDTH) * ROOM_HEIGHT;
    for (let x = 0; x < ROOM_WIDTH; x++) {
      solid[roomY][roomX + x] = true;
      solid[roomY + ROOM_HEIGHT - 1][roomX + x] = true;
    }
    for (let y = 0; y < ROOM_HEIGHT; y++) {
      solid[roomY + y][roomX] = true;
      solid[roomY + y][roomX + ROOM_WIDTH - 1] = true;
    }

    const ports = level.roomPorts[room];
    if (ports & PORT_WEST) for (let y = 5; y <= 6; y++) solid[roomY + y][roomX] = false;
    if (ports & PORT_EAST) for (let y = 5; y <= 6; y++) solid[roomY + y][roomX + ROOM_WIDTH - 1] = false;
    if (ports & PORT_NORTH) {
      for (let x = 4; x <= 6; x++) {
        solid[roomY][roomX + x] = false;
        solid[roomY + 3][roomX + x] = true;
      }
    }
    if (ports & PORT_SOUTH) for (let x = 4; x <= 6; x++) solid[roomY + ROOM_HEIGHT - 1][roomX + x] = false;
  }

  const tiles = solid.map((row, y) => row.map((occupied, x) => {
    if (!occupied) return 17;
    return 1 +
      (y > 0 && solid[y - 1][x] ? 1 : 0) +
      (x < LEVEL_WIDTH - 1 && solid[y][x + 1] ? 2 : 0) +
      (y < LEVEL_HEIGHT - 1 && solid[y + 1][x] ? 4 : 0) +
      (x > 0 && solid[y][x - 1] ? 8 : 0);
  }));

  const exitX = (level.exitRoom % GRID_WIDTH) * ROOM_WIDTH + 4;
  const exitY = Math.floor(level.exitRoom / GRID_WIDTH) * ROOM_HEIGHT + 4;
  for (let row = 0; row < 3; row++) {
    for (let column = 0; column < 2; column++) tiles[exitY + row][exitX + column] = 25 + row * 2 + column;
  }

  return tiles.flat();
}

export function validateLevel(level) {
  const errors = [];
  const route = level.criticalRoute;
  const routeSet = new Set(route);

  if (route.length < 4 || route.length > 16) errors.push(`route length ${route.length} is outside 4–16`);
  if (routeSet.size !== route.length) errors.push('critical route repeats a room');
  if (Math.floor(level.spawnRoom / GRID_WIDTH) !== 0) errors.push('spawn is not on the top row');
  if (Math.floor(level.exitRoom / GRID_WIDTH) !== GRID_HEIGHT - 1) errors.push('exit is not on the bottom row');

  let southEdges = 0;
  const expectedPorts = Array(GRID_WIDTH * GRID_HEIGHT).fill(0);
  const horizontalDirections = Array(GRID_HEIGHT).fill(0);
  for (let index = 1; index < route.length; index++) {
    const from = route[index - 1];
    const to = route[index];
    const delta = to - from;
    if (![1, -1, GRID_WIDTH].includes(delta)) {
      errors.push(`invalid route edge ${from}→${to}`);
      continue;
    }
    const fromPort = portFromRoomToRoom(from, to);
    const toPort = portFromRoomToRoom(to, from);
    expectedPorts[from] |= fromPort;
    expectedPorts[to] |= toPort;
    if (delta === GRID_WIDTH) southEdges++;
    if (Math.abs(delta) === 1) {
      const row = Math.floor(from / GRID_WIDTH);
      const direction = Math.sign(delta);
      if (horizontalDirections[row] && horizontalDirections[row] !== direction) errors.push(`route reverses on row ${row}`);
      horizontalDirections[row] = direction;
    }
  }
  if (southEdges !== GRID_HEIGHT - 1) errors.push(`route has ${southEdges} south edges instead of 3`);
  if (level.branchEdges.length !== GRID_WIDTH * GRID_HEIGHT - route.length) {
    errors.push(`level has ${level.branchEdges.length} branch edges instead of ${GRID_WIDTH * GRID_HEIGHT - route.length}`);
  }

  for (let room = 0; room < level.roomPorts.length; room++) {
    const ports = level.roomPorts[room];
    const row = Math.floor(room / GRID_WIDTH);
    const column = room % GRID_WIDTH;
    if ((ports & expectedPorts[room]) !== expectedPorts[room]) errors.push(`room ${room} is missing a critical-route port`);
    if (column === 0 && ports & PORT_WEST) errors.push(`room ${room} opens west out of bounds`);
    if (column === GRID_WIDTH - 1 && ports & PORT_EAST) errors.push(`room ${room} opens east out of bounds`);
    if (row === 0 && ports & PORT_NORTH) errors.push(`room ${room} opens north out of bounds`);
    if (row === GRID_HEIGHT - 1 && ports & PORT_SOUTH) errors.push(`room ${room} opens south out of bounds`);
    if (ports & PORT_EAST && !(level.roomPorts[room + 1] & PORT_WEST)) errors.push(`room ${room} east port is unpaired`);
    if (ports & PORT_WEST && !(level.roomPorts[room - 1] & PORT_EAST)) errors.push(`room ${room} west port is unpaired`);
    if (ports & PORT_SOUTH && !(level.roomPorts[room + GRID_WIDTH] & PORT_NORTH)) errors.push(`room ${room} south port is unpaired`);
    if (ports & PORT_NORTH && !(level.roomPorts[room - GRID_WIDTH] & PORT_SOUTH)) errors.push(`room ${room} north port is unpaired`);
  }

  const reachable = new Set([level.spawnRoom]);
  const pending = [level.spawnRoom];
  while (pending.length) {
    const room = pending.pop();
    const ports = level.roomPorts[room];
    const neighbors = [];
    if (ports & PORT_WEST) neighbors.push(room - 1);
    if (ports & PORT_EAST) neighbors.push(room + 1);
    if (ports & PORT_NORTH) neighbors.push(room - GRID_WIDTH);
    if (ports & PORT_SOUTH) neighbors.push(room + GRID_WIDTH);
    for (const neighbor of neighbors) {
      if (!reachable.has(neighbor)) {
        reachable.add(neighbor);
        pending.push(neighbor);
      }
    }
  }
  if (reachable.size !== GRID_WIDTH * GRID_HEIGHT) errors.push(`${reachable.size} of 16 rooms are reachable from spawn`);

  const connectionCount = level.roomPorts.reduce((total, ports) => total +
    Boolean(ports & PORT_EAST) + Boolean(ports & PORT_SOUTH), 0);
  if (connectionCount !== GRID_WIDTH * GRID_HEIGHT - 1) errors.push(`room graph has ${connectionCount} connections instead of 15`);

  if (level.tiles.length !== LEVEL_WIDTH * LEVEL_HEIGHT) errors.push(`tile map has ${level.tiles.length} cells instead of 1280`);
  if (level.tiles.some(tile => tile < 0 || tile > 127)) errors.push('tile map contains an invalid tile ID');

  return { valid: errors.length === 0, errors };
}

function xmlEscape(value) {
  return String(value).replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('"', '&quot;');
}

export function levelToTmx(level, tilesetSource) {
  const points = level.criticalRoute.map(room => {
    const x = (room % GRID_WIDTH) * ROOM_WIDTH * 8 + ROOM_WIDTH * 4;
    const y = Math.floor(room / GRID_WIDTH) * ROOM_HEIGHT * 8 + ROOM_HEIGHT * 4;
    return `${x},${y}`;
  }).join(' ');
  const seed = level.seed ?? 'topology';
  return [
    '<?xml version="1.0" encoding="UTF-8"?>',
    `<map version="1.10" tiledversion="1.12.2" orientation="orthogonal" renderorder="right-down" width="${LEVEL_WIDTH}" height="${LEVEL_HEIGHT}" tilewidth="8" tileheight="8" infinite="0" backgroundcolor="#ffffff">`,
    ` <properties><property name="seed" value="${xmlEscape(seed)}"/><property name="route_length" type="int" value="${level.criticalRouteLength}"/></properties>`,
    ` <tileset firstgid="1" source="${xmlEscape(tilesetSource)}"/>`,
    ` <layer id="1" name="Connectivity Scaffold" width="${LEVEL_WIDTH}" height="${LEVEL_HEIGHT}">`,
    '  <data encoding="csv">',
    Array.from({ length: LEVEL_HEIGHT }, (_, row) => level.tiles.slice(row * LEVEL_WIDTH, (row + 1) * LEVEL_WIDTH).map(tile => tile + 1).join(',')).join(',\n'),
    '  </data>',
    ' </layer>',
    ' <objectgroup id="2" name="Critical Route">',
    `  <object id="1" name="seed-${xmlEscape(seed)}" x="0" y="0"><polyline points="${points}"/></object>`,
    ' </objectgroup>',
    '</map>',
    '',
  ].join('\n');
}

export function levelToSvg(level) {
  let solidPath = '';
  for (let index = 0; index < level.tiles.length; index++) {
    if (level.tiles[index] >= 1 && level.tiles[index] <= 16) {
      const x = index % LEVEL_WIDTH;
      const y = Math.floor(index / LEVEL_WIDTH);
      solidPath += `M${x} ${y}h1v1h-1z`;
    }
  }
  const routePoints = level.criticalRoute.map(room => `${(room % GRID_WIDTH) * ROOM_WIDTH + ROOM_WIDTH / 2},${Math.floor(room / GRID_WIDTH) * ROOM_HEIGHT + ROOM_HEIGHT / 2}`).join(' ');
  const spawn = level.spawnRoom;
  const exit = level.exitRoom;
  return `<svg viewBox="0 0 ${LEVEL_WIDTH} ${LEVEL_HEIGHT}" role="img" aria-label="Seed ${level.seed} connectivity map"><rect width="40" height="32" fill="#cadb94"/><path d="${solidPath}" fill="#354f34"/><path d="M10 0V32M20 0V32M30 0V32M0 8H40M0 16H40M0 24H40" fill="none" stroke="#789064" stroke-width=".12"/><polyline points="${routePoints}" fill="none" stroke="#c13d3d" stroke-width=".6" stroke-linecap="round" stroke-linejoin="round"/><circle cx="${(spawn % GRID_WIDTH) * ROOM_WIDTH + ROOM_WIDTH / 2}" cy="${Math.floor(spawn / GRID_WIDTH) * ROOM_HEIGHT + ROOM_HEIGHT / 2}" r="1.2" fill="#fff" stroke="#17351d" stroke-width=".35"/><rect x="${(exit % GRID_WIDTH) * ROOM_WIDTH + ROOM_WIDTH / 2 - 1}" y="${Math.floor(exit / GRID_WIDTH) * ROOM_HEIGHT + ROOM_HEIGHT / 2 - 1}" width="2" height="2" fill="#111" stroke="#fff" stroke-width=".3"/></svg>`;
}

export function topologySignature(level) {
  return level.columns.join('');
}
