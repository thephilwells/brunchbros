import { readFileSync } from 'node:fs';
import {
  PORT_EAST,
  PORT_NORTH,
  PORT_SOUTH,
  PORT_WEST,
  ROOM_HEIGHT,
  ROOM_WIDTH,
  LEVEL_HEIGHT,
  LEVEL_WIDTH,
  TRAVERSAL_LEDGE_CATCH,
} from './level-generation.mjs';

const FURNITURE_MANIFEST = JSON.parse(readFileSync(new URL('../../data/dining-room-furniture.json', import.meta.url), 'utf8'));
const FURNITURE_BY_ID = new Map(FURNITURE_MANIFEST.components.map(component => [component.id, component]));
const BACKGROUND_MANIFEST = JSON.parse(readFileSync(new URL('../../data/dining-room-background.json', import.meta.url), 'utf8'));
const BACKGROUND_BY_ID = new Map(BACKGROUND_MANIFEST.components.map(component => [component.id, component]));
const WALLPAPER_MANIFEST = JSON.parse(readFileSync(new URL('../../data/dining-room-wallpaper.json', import.meta.url), 'utf8'));
const MOB_MANIFEST = JSON.parse(readFileSync(new URL('../../data/dining-room-mobs.json', import.meta.url), 'utf8'));
const MOB_BY_ID = new Map(MOB_MANIFEST.mobs.map(mob => [mob.id, mob]));
const MOB_ROSTERS = new Map(MOB_MANIFEST.levelKinds.map(levelKind => [levelKind.id, levelKind.mobs]));
const TREASURE_MANIFEST = JSON.parse(readFileSync(new URL('../../data/dining-room-treasure.json', import.meta.url), 'utf8'));

function componentLayouts(component) {
  return component.orientations ?? [{ id: 'default', tiles: component.tiles }];
}

function chooseFurnitureLayout(component, position, structuralTiles) {
  const layouts = componentLayouts(component);
  if (component.id !== 'dining_chair') return layouts[0];
  const row = position.y + component.height - 1;
  let leftDistance = 0;
  for (let x = position.x - 1; x >= 0; x--) {
    const tile = structuralTiles[row * LEVEL_WIDTH + x];
    if (tile >= 1 && tile <= 16) break;
    leftDistance++;
  }
  let rightDistance = 0;
  for (let x = position.x + component.width; x < LEVEL_WIDTH; x++) {
    const tile = structuralTiles[row * LEVEL_WIDTH + x];
    if (tile >= 1 && tile <= 16) break;
    rightDistance++;
  }
  const orientation = leftDistance <= rightDistance ? 'back_left' : 'back_right';
  return layouts.find(layout => layout.id === orientation);
}

export const RESERVATION_CRITICAL_ROUTE = 0x01;
export const RESERVATION_PORT = 0x02;
export const RESERVATION_WIDE_SEAM = 0x04;
export const RESERVATION_SPAWN = 0x08;
export const RESERVATION_EXIT = 0x10;
export const RESERVATION_LEDGE_CATCH = 0x20;
const BACKGROUND_BLOCKING_RESERVATIONS = RESERVATION_PORT | RESERVATION_WIDE_SEAM | RESERVATION_SPAWN | RESERVATION_EXIT | RESERVATION_LEDGE_CATCH;
const ENCOUNTER_BLOCKING_RESERVATIONS = RESERVATION_PORT | RESERVATION_WIDE_SEAM | RESERVATION_SPAWN | RESERVATION_EXIT | RESERVATION_LEDGE_CATCH;
const ONE_WAY_TILES = new Set([50, 51, 52, 53, 57, 58, 63, 77, 78, 112, 113, 114]);

function mixSelection(seed, room, salt) {
  let state = ((seed || 0xace1) ^ ((room + 1) * 0x9e37) ^ salt) & 0xffff;
  state = (state ^ state << 7) & 0xffff;
  state = (state ^ state >>> 9) & 0xffff;
  return (state ^ state << 8) & 0xffff;
}

export function addDiningRoomPlacementReservations(level) {
  const reservationMask = Array(LEVEL_WIDTH * LEVEL_HEIGHT).fill(0);
  const placementReservationRegions = [];

  const addRegion = (room, localX, localY, width, height, kind, flag) => {
    const roomX = room % 4 * ROOM_WIDTH;
    const roomY = Math.floor(room / 4) * ROOM_HEIGHT;
    const region = { room, x: roomX + localX, y: roomY + localY, width, height, kind, flag };
    placementReservationRegions.push(region);
    for (let y = region.y; y < region.y + height; y++) {
      for (let x = region.x; x < region.x + width; x++) reservationMask[y * LEVEL_WIDTH + x] |= flag;
    }
  };

  for (const room of level.criticalRoute) addRegion(room, 0, 0, ROOM_WIDTH, ROOM_HEIGHT, 'critical_route', RESERVATION_CRITICAL_ROUTE);

  for (let room = 0; room < level.roomPorts.length; room++) {
    const ports = level.roomPorts[room];
    const wide = level.roomWidePorts[room];
    if (ports & PORT_WEST) addRegion(room, 0, wide & PORT_WEST ? 0 : 3, 3, wide & PORT_WEST ? 8 : 4, wide & PORT_WEST ? 'wide_seam' : 'port', wide & PORT_WEST ? RESERVATION_WIDE_SEAM : RESERVATION_PORT);
    if (ports & PORT_EAST) addRegion(room, 7, wide & PORT_EAST ? 0 : 3, 3, wide & PORT_EAST ? 8 : 4, wide & PORT_EAST ? 'wide_seam' : 'port', wide & PORT_EAST ? RESERVATION_WIDE_SEAM : RESERVATION_PORT);
    if (ports & PORT_NORTH) addRegion(room, wide & PORT_NORTH ? 0 : 3, 0, wide & PORT_NORTH ? 10 : 5, 4, wide & PORT_NORTH ? 'wide_seam' : 'port', wide & PORT_NORTH ? RESERVATION_WIDE_SEAM : RESERVATION_PORT);
    if (ports & PORT_SOUTH) addRegion(room, wide & PORT_SOUTH ? 0 : 3, 4, wide & PORT_SOUTH ? 10 : 5, 4, wide & PORT_SOUTH ? 'wide_seam' : 'port', wide & PORT_SOUTH ? RESERVATION_WIDE_SEAM : RESERVATION_PORT);
    if (level.roomTraversalClasses[room] === TRAVERSAL_LEDGE_CATCH) addRegion(room, 0, 0, ROOM_WIDTH, ROOM_HEIGHT, 'ledge_catch', RESERVATION_LEDGE_CATCH);
  }

  addRegion(level.spawnRoom, 0, 0, 5, 8, 'spawn', RESERVATION_SPAWN);
  addRegion(level.exitRoom, 0, 0, 6, 8, 'exit', RESERVATION_EXIT);

  const composed = {
    ...level,
    placementReservationMask: reservationMask,
    placementReservationRegions,
  };
  composed.compositionValidation = validateDiningRoomPlacementReservations(composed);
  return composed;
}

export function validateDiningRoomPlacementReservations(level) {
  const errors = [];
  const mask = level.placementReservationMask;
  if (!Array.isArray(mask) || mask.length !== LEVEL_WIDTH * LEVEL_HEIGHT) return { valid: false, errors: ['placement reservation mask must contain 1,280 cells'] };

  for (const region of level.placementReservationRegions ?? []) {
    if (region.x < 0 || region.y < 0 || region.x + region.width > LEVEL_WIDTH || region.y + region.height > LEVEL_HEIGHT) {
      errors.push(`${region.kind} reservation in room ${region.room} leaves the level`);
      continue;
    }
    for (let y = region.y; y < region.y + region.height; y++) {
      for (let x = region.x; x < region.x + region.width; x++) {
        if (!(mask[y * LEVEL_WIDTH + x] & region.flag)) errors.push(`${region.kind} reservation in room ${region.room} is missing cell ${x},${y}`);
      }
    }
  }

  for (const room of level.criticalRoute) {
    const roomX = room % 4 * ROOM_WIDTH;
    const roomY = Math.floor(room / 4) * ROOM_HEIGHT;
    for (let y = roomY; y < roomY + ROOM_HEIGHT; y++) {
      for (let x = roomX; x < roomX + ROOM_WIDTH; x++) {
        if (!(mask[y * LEVEL_WIDTH + x] & RESERVATION_CRITICAL_ROUTE)) errors.push(`critical-route room ${room} leaves cell ${x},${y} unreserved`);
      }
    }
  }

  for (const [room, flag, label] of [[level.spawnRoom, RESERVATION_SPAWN, 'spawn'], [level.exitRoom, RESERVATION_EXIT, 'exit']]) {
    const region = level.placementReservationRegions.find(candidate => candidate.kind === label && candidate.room === room);
    if (!region) errors.push(`${label} room ${room} has no reservation`);
    else if (region.flag !== flag) errors.push(`${label} room ${room} has the wrong reservation flag`);
  }

  return { valid: errors.length === 0, errors };
}

function backgroundChambers(level) {
  const chambers = [];
  const visited = new Set();
  for (let room = 0; room < 16; room++) {
    if (visited.has(room)) continue;
    const wide = level.roomWidePorts[room];
    const neighbor = wide & PORT_WEST ? room - 1 : wide & PORT_EAST ? room + 1 : wide & PORT_NORTH ? room - 4 : wide & PORT_SOUTH ? room + 4 : null;
    const rooms = neighbor === null ? [room] : [room, neighbor].sort((a, b) => a - b);
    for (const member of rooms) visited.add(member);
    const floorRow = Math.max(...rooms.map(member => Math.floor(member / 4)));
    const mountingRooms = rooms.filter(member => Math.floor(member / 4) === floorRow);
    chambers.push({ anchor: rooms[0], rooms, mountingRooms });
  }
  return chambers;
}

function backgroundCandidates(level, component, room, sourceTiles) {
  const roomX = room % 4 * ROOM_WIDTH;
  const roomY = Math.floor(room / 4) * ROOM_HEIGHT;
  const candidates = [];
  const localY = ROOM_HEIGHT - 1 - component.floorClearance - component.height;
  for (let localX = 1; localX < ROOM_WIDTH - component.width; localX++) {
    let valid = true;
    for (let componentY = 0; componentY < component.height; componentY++) {
      for (let componentX = 0; componentX < component.width; componentX++) {
        const index = (roomY + localY + componentY) * LEVEL_WIDTH + roomX + localX + componentX;
        if (sourceTiles[index] !== BACKGROUND_MANIFEST.backgroundTile || level.placementReservationMask[index] & BACKGROUND_BLOCKING_RESERVATIONS) valid = false;
      }
    }
    if (valid) candidates.push({ room, x: roomX + localX, y: roomY + localY });
  }
  return candidates;
}

function backgroundOptions(component, chamber, candidates) {
  if (component.instances !== 2) return candidates.map(candidate => [candidate]);
  const left = Math.min(...chamber.mountingRooms.map(room => room % 4 * ROOM_WIDTH));
  const right = Math.max(...chamber.mountingRooms.map(room => room % 4 * ROOM_WIDTH + ROOM_WIDTH));
  const targets = [left + Math.floor((right - left) / 3), left + Math.floor((right - left) * 2 / 3)];
  const pair = targets.map(x => candidates.find(candidate => candidate.x === x));
  return pair.every(Boolean) ? [pair] : [];
}

export function addDiningRoomBackground(level) {
  const structuralTiles = [...level.tiles];
  const tiles = [...level.tiles];
  const roomBackgroundCandidateCounts = Array(16).fill(0);
  const backgroundPlacements = [];

  for (const chamber of backgroundChambers(level)) {
    const optionsByComponent = [];
    for (const component of BACKGROUND_MANIFEST.components) {
      const candidates = chamber.mountingRooms.flatMap(room => {
        const roomCandidates = backgroundCandidates(level, component, room, structuralTiles);
        roomBackgroundCandidateCounts[room] += roomCandidates.length;
        return roomCandidates;
      });
      const options = backgroundOptions(component, chamber, candidates);
      if (options.length) optionsByComponent.push({ component, options });
    }
    if (!optionsByComponent.length) continue;
    const group = optionsByComponent[mixSelection(level.seed, chamber.anchor, 0xb529) % optionsByComponent.length];
    const positions = group.options[mixSelection(level.seed, chamber.anchor, 0x68e3) % group.options.length];
    for (let instance = 0; instance < positions.length; instance++) {
      const position = positions[instance];
      const placement = {
        chamber: chamber.anchor,
        rooms: chamber.rooms,
        room: position.room,
        component: group.component.id,
        instance,
        instances: positions.length,
        x: position.x,
        y: position.y,
        width: group.component.width,
        height: group.component.height,
      };
      backgroundPlacements.push(placement);
      for (let componentY = 0; componentY < group.component.height; componentY++) {
        for (let componentX = 0; componentX < group.component.width; componentX++) {
          tiles[(position.y + componentY) * LEVEL_WIDTH + position.x + componentX] = group.component.tiles[componentY][componentX];
        }
      }
    }
  }

  return {
    ...level,
    tiles,
    structuralTiles,
    roomBackgroundCandidateCounts,
    backgroundPlacements,
  };
}

export function addDiningRoomFurniture(level) {
  const structuralTiles = level.structuralTiles ?? [...level.tiles];
  const tiles = [...level.tiles];
  const criticalRooms = new Set(level.criticalRoute);
  const furniturePlacements = [];
  const roomFurnitureCandidateCounts = Array(16).fill(0);

  for (let room = 0; room < 16; room++) {
    if (criticalRooms.has(room) || level.roomTraversalClasses[room] === TRAVERSAL_LEDGE_CATCH) continue;
    const roomX = room % 4 * ROOM_WIDTH;
    const roomY = Math.floor(room / 4) * ROOM_HEIGHT;
    const floorY = roomY + ROOM_HEIGHT - 1;
    const candidatesByComponent = [];

    for (const component of FURNITURE_MANIFEST.components) {
      const y = floorY - component.height;
      const candidates = [];
      for (let localX = 0; localX <= ROOM_WIDTH - component.width; localX++) {
        const x = roomX + localX;
        let valid = true;
        for (let offset = 0; offset < component.width; offset++) {
          if (structuralTiles[floorY * LEVEL_WIDTH + x + offset] < 1 || structuralTiles[floorY * LEVEL_WIDTH + x + offset] > 16) valid = false;
        }
        for (let componentY = 0; componentY < component.height; componentY++) {
          for (let componentX = 0; componentX < component.width; componentX++) {
            const index = (y + componentY) * LEVEL_WIDTH + x + componentX;
            if (tiles[index] !== FURNITURE_MANIFEST.backgroundTile || level.placementReservationMask[index]) valid = false;
          }
        }
        if (valid) candidates.push({ x, y });
      }
      roomFurnitureCandidateCounts[room] += candidates.length;
      if (candidates.length) candidatesByComponent.push({ component, candidates });
    }

    if (!candidatesByComponent.length) continue;
    const group = candidatesByComponent[mixSelection(level.seed, room, 0x41c6) % candidatesByComponent.length];
    const position = group.candidates[mixSelection(level.seed, room, 0x7f4a) % group.candidates.length];
    const layout = chooseFurnitureLayout(group.component, position, structuralTiles);
    const placement = {
      room,
      component: group.component.id,
      orientation: layout.id,
      x: position.x,
      y: position.y,
      width: group.component.width,
      height: group.component.height,
      floorY,
    };
    furniturePlacements.push(placement);
    for (let componentY = 0; componentY < group.component.height; componentY++) {
      for (let componentX = 0; componentX < group.component.width; componentX++) {
        tiles[(position.y + componentY) * LEVEL_WIDTH + position.x + componentX] = layout.tiles[componentY][componentX];
      }
    }
  }

  return {
    ...level,
    tiles,
    structuralTiles,
    roomFurnitureCandidateCounts,
    furniturePlacements,
  };
}

function wallpaperPlacementBlockers(level) {
  const blocked = new Set();
  for (const placement of [...(level.backgroundPlacements ?? []), ...(level.furniturePlacements ?? [])]) {
    for (let y = placement.y; y < placement.y + placement.height; y++) {
      for (let x = placement.x; x < placement.x + placement.width; x++) blocked.add(y * LEVEL_WIDTH + x);
    }
  }
  return blocked;
}

function wallpaperCandidates(level, chamber, sourceTiles, blocked) {
  const left = Math.min(...chamber.rooms.map(room => room % 4 * ROOM_WIDTH));
  const right = Math.max(...chamber.rooms.map(room => room % 4 * ROOM_WIDTH + ROOM_WIDTH));
  const top = Math.min(...chamber.rooms.map(room => Math.floor(room / 4) * ROOM_HEIGHT));
  const bottom = Math.max(...chamber.rooms.map(room => Math.floor(room / 4) * ROOM_HEIGHT + ROOM_HEIGHT));
  const candidates = [];
  for (let y = top + WALLPAPER_MANIFEST.yOffset; y < bottom - 1; y += WALLPAPER_MANIFEST.yStride) {
    for (let x = left + WALLPAPER_MANIFEST.xOffset; x < right - 1; x += WALLPAPER_MANIFEST.xStride) {
      const index = y * LEVEL_WIDTH + x;
      if (sourceTiles[index] !== WALLPAPER_MANIFEST.backgroundTile || blocked.has(index) || level.placementReservationMask[index] & BACKGROUND_BLOCKING_RESERVATIONS) continue;
      candidates.push({ room: Math.floor(y / ROOM_HEIGHT) * 4 + Math.floor(x / ROOM_WIDTH), x, y });
    }
  }
  return candidates;
}

function wallpaperSelections(level, chamber, candidates) {
  const count = Math.min(candidates.length, chamber.rooms.length * WALLPAPER_MANIFEST.maxPerRoomCell);
  if (!count) return [];
  const start = mixSelection(level.seed, chamber.anchor, WALLPAPER_MANIFEST.selectionSalt) % candidates.length;
  return Array.from({ length: count }, (_, index) => candidates[(start + Math.floor(index * candidates.length / count)) % candidates.length]);
}

export function addDiningRoomWallpaper(level) {
  const wallpaperSourceTiles = [...level.tiles];
  const tiles = [...level.tiles];
  const roomWallpaperCandidateCounts = Array(16).fill(0);
  const wallpaperPlacements = [];
  const blocked = wallpaperPlacementBlockers(level);

  for (const chamber of backgroundChambers(level)) {
    const candidates = wallpaperCandidates(level, chamber, wallpaperSourceTiles, blocked);
    for (const candidate of candidates) roomWallpaperCandidateCounts[candidate.room]++;
    for (const position of wallpaperSelections(level, chamber, candidates)) {
      wallpaperPlacements.push({
        chamber: chamber.anchor,
        rooms: chamber.rooms,
        room: position.room,
        x: position.x,
        y: position.y,
        tile: WALLPAPER_MANIFEST.motifTile,
      });
      tiles[position.y * LEVEL_WIDTH + position.x] = WALLPAPER_MANIFEST.motifTile;
    }
  }

  return {
    ...level,
    tiles,
    wallpaperSourceTiles,
    roomWallpaperCandidateCounts,
    wallpaperPlacements,
  };
}

function furnitureCells(level) {
  const cells = new Set();
  for (const placement of level.furniturePlacements ?? []) {
    for (let y = placement.y; y < placement.y + placement.height; y++) {
      for (let x = placement.x; x < placement.x + placement.width; x++) cells.add(y * LEVEL_WIDTH + x);
    }
  }
  return cells;
}

function mobCandidates(level, room, mob, occupiedFurniture, occupiedMobs = new Set()) {
  if (room === level.spawnRoom || room === level.exitRoom || level.roomTraversalClasses[room] === TRAVERSAL_LEDGE_CATCH) return [];
  const roomX = room % 4 * ROOM_WIDTH;
  const roomY = Math.floor(room / 4) * ROOM_HEIGHT;
  const candidates = [];
  const bodyOpen = (x, y) => {
    const index = y * LEVEL_WIDTH + x;
    return level.structuralTiles[index] === 17 && !(level.placementReservationMask[index] & ENCOUNTER_BLOCKING_RESERVATIONS) && !occupiedFurniture.has(index) && !occupiedMobs.has(index);
  };
  const solidSupport = (x, y) => {
    const index = y * LEVEL_WIDTH + x;
    const tile = level.structuralTiles[index];
    return tile >= 1 && tile <= 16 && !(level.placementReservationMask[index] & ENCOUNTER_BLOCKING_RESERVATIONS);
  };
  const burgerSupport = (x, y) => {
    const index = y * LEVEL_WIDTH + x;
    return (solidSupport(x, y) || ONE_WAY_TILES.has(level.tiles[index])) && !(level.placementReservationMask[index] & ENCOUNTER_BLOCKING_RESERVATIONS);
  };
  for (let y = roomY; y + mob.height < roomY + ROOM_HEIGHT; y++) {
    for (let x = roomX; x + mob.width <= roomX + ROOM_WIDTH; x++) {
      if (x <= roomX || x + mob.width >= roomX + ROOM_WIDTH) continue;
      let valid = true;
      for (let bodyY = y; bodyY < y + mob.height; bodyY++) {
        for (let bodyX = x; bodyX < x + mob.width; bodyX++) {
          if (!bodyOpen(bodyX, bodyY)) valid = false;
        }
        const leftIndex = bodyY * LEVEL_WIDTH + x - 1;
        const rightIndex = bodyY * LEVEL_WIDTH + x + mob.width;
        if (level.structuralTiles[leftIndex] !== 17 || ONE_WAY_TILES.has(level.tiles[leftIndex]) || level.structuralTiles[rightIndex] !== 17 || ONE_WAY_TILES.has(level.tiles[rightIndex])) valid = false;
      }
      if (!valid) continue;
      if (mob.id === 'pancake') {
        const floorY = y + 5;
        const hasRoomFloor = floorY < roomY + ROOM_HEIGHT && Array.from({ length: ROOM_WIDTH - 2 }, (_, offset) => roomX + 1 + offset).some(floorX => {
          const tile = level.structuralTiles[floorY * LEVEL_WIDTH + floorX];
          return tile >= 1 && tile <= 16;
        });
        if (hasRoomFloor) candidates.push({ room, x, y, direction: 'right' });
        continue;
      }
      if (mob.id === 'burger' || mob.id === 'fried_egg') {
        if ([0, 1].every(offset => burgerSupport(x + offset, y + mob.height))) candidates.push({ room, x, y, direction: 'right' });
        continue;
      }
      if ([0, 1].every(offset => solidSupport(x + offset, y + mob.height))) candidates.push({ room, x, y, direction: 'right' });
      else if (y > roomY && [0, 1].every(offset => solidSupport(x + offset, y - 1))) candidates.push({ room, x, y, direction: 'left' });
    }
  }
  return candidates;
}

function mobSelections(level, levelKind) {
  const occupiedFurniture = furnitureCells(level);
  const occupiedMobs = new Set();
  const eligible = new Set(MOB_ROSTERS.get(levelKind));
  const priority = MOB_MANIFEST.population.placementOrder.filter(id => eligible.has(id)).map(id => MOB_BY_ID.get(id));
  const candidatesByRoom = Array.from({ length: 16 }, (_, room) => priority.reduce((total, mob) => total + mobCandidates(level, room, mob, occupiedFurniture).length, 0));
  const placements = [];
  for (const mob of priority) {
    const typeIndex = mob.runtimeType;
    for (let instance = 0; instance < mob.minimum; instance++) {
      const selectionSalt = MOB_MANIFEST.population.selectionSalt ^ typeIndex * 0x101 ^ instance;
      const positionSalt = MOB_MANIFEST.population.positionSalt ^ typeIndex * 0x101 ^ instance;
      const rooms = Array.from({ length: 16 }, (_, room) => ({ room, candidates: mobCandidates(level, room, mob, occupiedFurniture, occupiedMobs) })).filter(entry => entry.candidates.length);
      rooms.sort((left, right) => mixSelection(level.seed, left.room, selectionSalt) - mixSelection(level.seed, right.room, selectionSalt) || left.room - right.room);
      const selectedRoom = rooms[0];
      if (!selectedRoom) continue;
      const position = selectedRoom.candidates[mixSelection(level.seed, selectedRoom.room, positionSalt) % selectedRoom.candidates.length];
      for (let y = position.y; y < position.y + mob.height; y++) for (let x = position.x; x < position.x + mob.width; x++) occupiedMobs.add(y * LEVEL_WIDTH + x);
      placements.push({
        room: selectedRoom.room,
        mob: mob.id,
        frequency: mob.frequency,
        direction: position.direction,
        x: position.x,
        y: position.y,
        width: mob.width,
        height: mob.height,
      });
    }
  }
  const target = priority.reduce((total, mob) => total + mob.minimum, 0);
  return { candidatesByRoom, placements, target };
}

export function addDiningRoomMobs(level, levelKind = 'dining_room_1') {
  if (!MOB_ROSTERS.has(levelKind)) throw new Error(`Unknown Dining Room level kind ${levelKind}`);
  const selection = mobSelections(level, levelKind);
  return {
    ...level,
    levelKind,
    roomMobCandidateCounts: selection.candidatesByRoom,
    mobPopulationTarget: selection.target,
    mobPlacements: selection.placements,
  };
}

function placementCells(placements) {
  const cells = new Set();
  for (const placement of placements) {
    for (let y = placement.y; y < placement.y + placement.height; y++) {
      for (let x = placement.x; x < placement.x + placement.width; x++) cells.add(y * LEVEL_WIDTH + x);
    }
  }
  return cells;
}

function roomDistancesFromCriticalRoute(level) {
  const distances = Array(16).fill(Infinity);
  const queue = [...level.criticalRoute];
  for (const room of queue) distances[room] = 0;
  for (let index = 0; index < queue.length; index++) {
    const room = queue[index];
    const row = Math.floor(room / 4);
    const column = room % 4;
    const neighbors = [];
    if (column > 0 && level.roomPorts[room] & PORT_WEST) neighbors.push(room - 1);
    if (column < 3 && level.roomPorts[room] & PORT_EAST) neighbors.push(room + 1);
    if (row > 0 && level.roomPorts[room] & PORT_NORTH) neighbors.push(room - 4);
    if (row < 3 && level.roomPorts[room] & PORT_SOUTH) neighbors.push(room + 4);
    for (const neighbor of neighbors) {
      if (distances[neighbor] <= distances[room] + 1) continue;
      distances[neighbor] = distances[room] + 1;
      queue.push(neighbor);
    }
  }
  return distances;
}

function treasureCandidates(level, room, occupied) {
  if (room === level.spawnRoom || room === level.exitRoom || level.roomTraversalClasses[room] === TRAVERSAL_LEDGE_CATCH) return [];
  const roomX = room % 4 * ROOM_WIDTH;
  const roomY = Math.floor(room / 4) * ROOM_HEIGHT;
  const candidates = [];
  for (let y = roomY; y + TREASURE_MANIFEST.height < roomY + ROOM_HEIGHT; y++) {
    for (let x = roomX + 1; x + TREASURE_MANIFEST.width < roomX + ROOM_WIDTH; x++) {
      let valid = true;
      for (let bodyY = y; bodyY < y + TREASURE_MANIFEST.height; bodyY++) {
        for (let bodyX = x; bodyX < x + TREASURE_MANIFEST.width; bodyX++) {
          const index = bodyY * LEVEL_WIDTH + bodyX;
          if (level.structuralTiles[index] !== 17 || occupied.has(index) || level.placementReservationMask[index] & ENCOUNTER_BLOCKING_RESERVATIONS) valid = false;
        }
      }
      for (let supportX = x; supportX < x + TREASURE_MANIFEST.width; supportX++) {
        const index = (y + TREASURE_MANIFEST.height) * LEVEL_WIDTH + supportX;
        const tile = level.structuralTiles[index];
        if (!((tile >= 1 && tile <= 16) || ONE_WAY_TILES.has(level.tiles[index]))) valid = false;
      }
      if (valid) candidates.push({ room, x, y });
    }
  }
  return candidates;
}

function treasureSelections(level) {
  const occupied = placementCells([...(level.furniturePlacements ?? []), ...(level.mobPlacements ?? [])]);
  const distances = roomDistancesFromCriticalRoute(level);
  const candidatesByRoom = Array.from({ length: 16 }, (_, room) => treasureCandidates(level, room, occupied));
  const target = TREASURE_MANIFEST.minimum + mixSelection(level.seed, 0, TREASURE_MANIFEST.countSalt) % (TREASURE_MANIFEST.maximum - TREASURE_MANIFEST.minimum + 1);
  const placements = [];
  for (let instance = 0; instance < target; instance++) {
    const rooms = Array.from({ length: 16 }, (_, room) => ({ room, candidates: treasureCandidates(level, room, occupied) })).filter(entry => entry.candidates.length);
    rooms.sort((left, right) => distances[right.room] - distances[left.room] || Number(placements.some(placement => placement.room === left.room)) - Number(placements.some(placement => placement.room === right.room)) || mixSelection(level.seed, left.room, TREASURE_MANIFEST.roomSalt ^ instance) - mixSelection(level.seed, right.room, TREASURE_MANIFEST.roomSalt ^ instance) || left.room - right.room);
    const selected = rooms[0];
    if (!selected) break;
    const position = selected.candidates[mixSelection(level.seed, selected.room, TREASURE_MANIFEST.positionSalt ^ instance) % selected.candidates.length];
    for (let y = position.y; y < position.y + TREASURE_MANIFEST.height; y++) {
      for (let x = position.x; x < position.x + TREASURE_MANIFEST.width; x++) occupied.add(y * LEVEL_WIDTH + x);
    }
    placements.push({
      room: selected.room,
      distanceFromCriticalRoute: distances[selected.room],
      contents: mixSelection(level.seed, selected.room, TREASURE_MANIFEST.contentsSalt ^ instance) & 1 ? 'heart' : 'empty',
      x: position.x,
      y: position.y,
      width: TREASURE_MANIFEST.width,
      height: TREASURE_MANIFEST.height,
    });
  }
  if (placements.length && placements.every(placement => placement.contents === 'empty')) {
    placements[mixSelection(level.seed, 0, TREASURE_MANIFEST.promotionSalt) % placements.length].contents = 'heart';
  }
  return { candidatesByRoom: candidatesByRoom.map(candidates => candidates.length), distances, placements, target };
}

export function addDiningRoomTreasure(level) {
  const selection = treasureSelections(level);
  return {
    ...level,
    roomTreasureCandidateCounts: selection.candidatesByRoom,
    roomDistancesFromCriticalRoute: selection.distances,
    treasurePopulationTarget: selection.target,
    treasurePlacements: selection.placements,
  };
}

export function composeDiningRoomFixtures(level) {
  return addDiningRoomFurniture(addDiningRoomBackground(addDiningRoomPlacementReservations(level)));
}

export function composeDiningRoom(level, levelKind = 'dining_room_1') {
  const composed = addDiningRoomTreasure(addDiningRoomMobs(addDiningRoomWallpaper(composeDiningRoomFixtures(level)), levelKind));
  composed.compositionValidation = validateDiningRoomComposition(composed);
  return composed;
}

export function validateDiningRoomComposition(level) {
  const errors = [...validateDiningRoomPlacementReservations(level).errors];
  const eligibleMobs = new Set(MOB_ROSTERS.get(level.levelKind) ?? []);
  if (!MOB_ROSTERS.has(level.levelKind)) errors.push(`unknown Dining Room level kind ${level.levelKind}`);
  if (!Array.isArray(level.structuralTiles) || level.structuralTiles.length !== LEVEL_WIDTH * LEVEL_HEIGHT) errors.push('structural tile snapshot must contain 1,280 cells');
  if (!Array.isArray(level.roomBackgroundCandidateCounts) || level.roomBackgroundCandidateCounts.length !== 16) errors.push('room background candidate counts must contain 16 entries');
  if (!Array.isArray(level.roomFurnitureCandidateCounts) || level.roomFurnitureCandidateCounts.length !== 16) errors.push('room furniture candidate counts must contain 16 entries');
  if (!Array.isArray(level.wallpaperSourceTiles) || level.wallpaperSourceTiles.length !== LEVEL_WIDTH * LEVEL_HEIGHT) errors.push('wallpaper source tile snapshot must contain 1,280 cells');
  if (!Array.isArray(level.roomWallpaperCandidateCounts) || level.roomWallpaperCandidateCounts.length !== 16) errors.push('room wallpaper candidate counts must contain 16 entries');
  if (!Array.isArray(level.roomMobCandidateCounts) || level.roomMobCandidateCounts.length !== 16) errors.push('room mob candidate counts must contain 16 entries');
  if (!Array.isArray(level.roomTreasureCandidateCounts) || level.roomTreasureCandidateCounts.length !== 16) errors.push('room treasure candidate counts must contain 16 entries');
  if (!Array.isArray(level.roomDistancesFromCriticalRoute) || level.roomDistancesFromCriticalRoute.length !== 16) errors.push('room distances from critical route must contain 16 entries');
  if (errors.length) return { valid: false, errors };

  const occupied = new Set();
  const backgroundPlacementsByChamber = new Map();
  for (const placement of level.backgroundPlacements ?? []) {
    const component = BACKGROUND_BY_ID.get(placement.component);
    if (!component) {
      errors.push(`room ${placement.room} uses unknown background fixture ${placement.component}`);
      continue;
    }
    const chamber = backgroundChambers(level).find(candidate => candidate.anchor === placement.chamber);
    if (!chamber || !chamber.mountingRooms.includes(placement.room)) errors.push(`${placement.component} has invalid chamber floor ${placement.chamber}`);
    const chamberPlacements = backgroundPlacementsByChamber.get(placement.chamber) ?? [];
    chamberPlacements.push(placement);
    backgroundPlacementsByChamber.set(placement.chamber, chamberPlacements);
    const roomX = placement.room % 4 * ROOM_WIDTH;
    const roomY = Math.floor(placement.room / 4) * ROOM_HEIGHT;
    const localY = placement.y - roomY;
    const expectedLocalY = ROOM_HEIGHT - 1 - component.floorClearance - component.height;
    if (placement.x <= roomX || placement.x + component.width >= roomX + ROOM_WIDTH || localY !== expectedLocalY) errors.push(`${placement.component} leaves its floor-relative mounting line in room ${placement.room}`);
    if (placement.width !== component.width || placement.height !== component.height) errors.push(`${placement.component} metadata is inconsistent in room ${placement.room}`);
    for (let y = 0; y < component.height; y++) {
      for (let x = 0; x < component.width; x++) {
        const mapX = placement.x + x;
        const mapY = placement.y + y;
        const index = mapY * LEVEL_WIDTH + mapX;
        if (occupied.has(index)) errors.push(`${placement.component} overlaps another fixture at ${mapX},${mapY}`);
        occupied.add(index);
        if (level.placementReservationMask[index] & BACKGROUND_BLOCKING_RESERVATIONS) errors.push(`${placement.component} occupies protected background cell ${mapX},${mapY}`);
        if (level.structuralTiles[index] !== BACKGROUND_MANIFEST.backgroundTile) errors.push(`${placement.component} replaces structural tile ${mapX},${mapY}`);
        if (level.tiles[index] !== component.tiles[y][x]) errors.push(`${placement.component} has the wrong tile at ${mapX},${mapY}`);
      }
    }
  }

  for (let room = 0; room < 16; room++) {
    const chamber = backgroundChambers(level).find(candidate => candidate.mountingRooms.includes(room));
    const expectedCount = chamber ? BACKGROUND_MANIFEST.components.reduce((total, component) => total + backgroundCandidates(level, component, room, level.structuralTiles).length, 0) : 0;
    if (level.roomBackgroundCandidateCounts[room] !== expectedCount) errors.push(`room ${room} has the wrong background candidate count`);
  }
  for (const chamber of backgroundChambers(level)) {
    const eligibleComponents = BACKGROUND_MANIFEST.components.filter(component => {
      const candidates = chamber.mountingRooms.flatMap(room => backgroundCandidates(level, component, room, level.structuralTiles));
      return backgroundOptions(component, chamber, candidates).length;
    });
    const placements = backgroundPlacementsByChamber.get(chamber.anchor) ?? [];
    if (eligibleComponents.length && !placements.length) errors.push(`eligible chamber ${chamber.anchor} has no background fixture`);
    if (!eligibleComponents.length && placements.length) errors.push(`ineligible chamber ${chamber.anchor} has a background fixture`);
    if (!placements.length) continue;
    const component = BACKGROUND_BY_ID.get(placements[0].component);
    if (placements.some(placement => placement.component !== component.id)) errors.push(`chamber ${chamber.anchor} mixes background fixtures`);
    const expectedInstances = component.instances ?? 1;
    if (placements.length !== expectedInstances) errors.push(`${component.id} has ${placements.length} instances instead of ${expectedInstances} in chamber ${chamber.anchor}`);
    if (placements.some((placement, index) => placement.instance !== index || placement.instances !== expectedInstances)) errors.push(`${component.id} has inconsistent instance metadata in chamber ${chamber.anchor}`);
    if (component.instances === 2) {
      const candidates = chamber.mountingRooms.flatMap(room => backgroundCandidates(level, component, room, level.structuralTiles));
      const expected = backgroundOptions(component, chamber, candidates)[0] ?? [];
      if (placements.some((placement, index) => placement.x !== expected[index]?.x || placement.y !== expected[index]?.y)) errors.push(`${component.id} is not evenly spaced in chamber ${chamber.anchor}`);
    }
  }

  const placementsByRoom = new Map();
  for (const placement of level.furniturePlacements ?? []) {
    const component = FURNITURE_BY_ID.get(placement.component);
    if (!component) {
      errors.push(`room ${placement.room} uses unknown furniture ${placement.component}`);
      continue;
    }
    const layout = componentLayouts(component).find(candidate => candidate.id === placement.orientation);
    if (!layout) {
      errors.push(`${placement.component} has unknown orientation ${placement.orientation}`);
      continue;
    }
    const expectedLayout = chooseFurnitureLayout(component, placement, level.structuralTiles);
    if (layout.id !== expectedLayout.id) errors.push(`${placement.component} faces away from its nearest wall in room ${placement.room}`);
    if (level.criticalRoute.includes(placement.room)) errors.push(`critical-route room ${placement.room} contains furniture`);
    if (level.roomTraversalClasses[placement.room] === TRAVERSAL_LEDGE_CATCH) errors.push(`ledge-catch room ${placement.room} contains furniture`);
    if (placementsByRoom.has(placement.room)) errors.push(`room ${placement.room} contains multiple furniture groups`);
    placementsByRoom.set(placement.room, placement);
    const roomX = placement.room % 4 * ROOM_WIDTH;
    const roomY = Math.floor(placement.room / 4) * ROOM_HEIGHT;
    if (placement.x < roomX || placement.y < roomY || placement.x + component.width > roomX + ROOM_WIDTH || placement.y + component.height > roomY + ROOM_HEIGHT) errors.push(`${placement.component} leaves room ${placement.room}`);
    if (placement.width !== component.width || placement.height !== component.height || placement.floorY !== roomY + ROOM_HEIGHT - 1) errors.push(`${placement.component} metadata is inconsistent in room ${placement.room}`);

    for (let x = placement.x; x < placement.x + component.width; x++) {
      const support = level.structuralTiles[placement.floorY * LEVEL_WIDTH + x];
      if (support < 1 || support > 16) errors.push(`${placement.component} lacks floor support at ${x},${placement.floorY}`);
    }
    for (let y = 0; y < component.height; y++) {
      for (let x = 0; x < component.width; x++) {
        const mapX = placement.x + x;
        const mapY = placement.y + y;
        const index = mapY * LEVEL_WIDTH + mapX;
        if (occupied.has(index)) errors.push(`${placement.component} overlaps furniture at ${mapX},${mapY}`);
        occupied.add(index);
        if (level.placementReservationMask[index]) errors.push(`${placement.component} occupies reserved cell ${mapX},${mapY}`);
        if (level.structuralTiles[index] !== FURNITURE_MANIFEST.backgroundTile) errors.push(`${placement.component} replaces structural tile ${mapX},${mapY}`);
        if (level.tiles[index] !== layout.tiles[y][x]) errors.push(`${placement.component} has the wrong tile at ${mapX},${mapY}`);
      }
    }
  }

  for (let room = 0; room < 16; room++) {
    if (level.roomFurnitureCandidateCounts[room] > 0 && !placementsByRoom.has(room)) errors.push(`eligible room ${room} has no furniture`);
    if (level.roomFurnitureCandidateCounts[room] === 0 && placementsByRoom.has(room)) errors.push(`ineligible room ${room} has furniture`);
  }

  const wallpaperPlacementsByChamber = new Map();
  const wallpaperOccupied = new Set();
  for (const placement of level.wallpaperPlacements ?? []) {
    const chamber = backgroundChambers(level).find(candidate => candidate.anchor === placement.chamber);
    if (!chamber || !chamber.rooms.includes(placement.room)) errors.push(`wallpaper motif has invalid chamber ${placement.chamber}`);
    const placements = wallpaperPlacementsByChamber.get(placement.chamber) ?? [];
    placements.push(placement);
    wallpaperPlacementsByChamber.set(placement.chamber, placements);
    const index = placement.y * LEVEL_WIDTH + placement.x;
    if (placement.tile !== WALLPAPER_MANIFEST.motifTile) errors.push(`wallpaper motif has invalid tile ${placement.tile}`);
    if (occupied.has(index)) errors.push(`wallpaper motif overlaps another placement at ${placement.x},${placement.y}`);
    occupied.add(index);
    wallpaperOccupied.add(index);
    if (level.placementReservationMask[index] & BACKGROUND_BLOCKING_RESERVATIONS) errors.push(`wallpaper motif occupies protected cell ${placement.x},${placement.y}`);
    if (level.wallpaperSourceTiles[index] !== WALLPAPER_MANIFEST.backgroundTile) errors.push(`wallpaper motif replaces decorated tile ${placement.x},${placement.y}`);
    if (level.tiles[index] !== WALLPAPER_MANIFEST.motifTile) errors.push(`wallpaper motif has the wrong tile at ${placement.x},${placement.y}`);
  }

  const expectedWallpaperCandidateCounts = Array(16).fill(0);
  const wallpaperBlocked = wallpaperPlacementBlockers(level);
  for (const chamber of backgroundChambers(level)) {
    const candidates = wallpaperCandidates(level, chamber, level.wallpaperSourceTiles, wallpaperBlocked);
    for (const candidate of candidates) expectedWallpaperCandidateCounts[candidate.room]++;
    const expected = wallpaperSelections(level, chamber, candidates);
    const placements = wallpaperPlacementsByChamber.get(chamber.anchor) ?? [];
    if (placements.length !== expected.length) errors.push(`chamber ${chamber.anchor} has ${placements.length} wallpaper motifs instead of ${expected.length}`);
    if (placements.some((placement, index) => placement.x !== expected[index]?.x || placement.y !== expected[index]?.y || placement.room !== expected[index]?.room)) errors.push(`chamber ${chamber.anchor} has incorrect wallpaper motif positions`);
  }
  if (level.roomWallpaperCandidateCounts.some((count, room) => count !== expectedWallpaperCandidateCounts[room])) errors.push('room wallpaper candidate counts are inconsistent');

  const expectedMobs = mobSelections(level, level.levelKind);
  if (level.mobPopulationTarget !== expectedMobs.target) errors.push('mob population target is inconsistent');
  if (level.roomMobCandidateCounts.some((count, room) => count !== expectedMobs.candidatesByRoom[room])) errors.push('room mob candidate counts are inconsistent');
  if (JSON.stringify(level.mobPlacements) !== JSON.stringify(expectedMobs.placements)) errors.push('mob placements are inconsistent');
  const mobCounts = new Map();
  const occupiedMobCells = new Set();
  const occupiedFurnitureCells = furnitureCells(level);
  for (const placement of level.mobPlacements ?? []) {
    const mob = MOB_BY_ID.get(placement.mob);
    if (!mob) {
      errors.push(`room ${placement.room} uses unknown mob ${placement.mob}`);
      continue;
    }
    if (!eligibleMobs.has(mob.id)) errors.push(`${mob.id} is not eligible for ${level.levelKind}`);
    mobCounts.set(placement.mob, (mobCounts.get(placement.mob) ?? 0) + 1);
    if (placement.room === level.spawnRoom || placement.room === level.exitRoom) errors.push(`protected endpoint room ${placement.room} contains a mob`);
    if (level.roomTraversalClasses[placement.room] === TRAVERSAL_LEDGE_CATCH) errors.push(`ledge-catch room ${placement.room} contains a mob`);
    if (placement.width !== mob.width || placement.height !== mob.height || placement.frequency !== mob.frequency) errors.push(`${placement.mob} metadata is inconsistent in room ${placement.room}`);
    for (let y = placement.y; y < placement.y + placement.height; y++) {
      for (let x = placement.x; x < placement.x + placement.width; x++) {
        const index = y * LEVEL_WIDTH + x;
        if (level.structuralTiles[index] !== 17) errors.push(`${placement.mob} body is obstructed at ${x},${y}`);
        if (level.placementReservationMask[index] & ENCOUNTER_BLOCKING_RESERVATIONS) errors.push(`${placement.mob} occupies protected encounter cell ${x},${y}`);
        if (occupiedFurnitureCells.has(index)) errors.push(`${placement.mob} overlaps furniture at ${x},${y}`);
        if (occupiedMobCells.has(index)) errors.push(`${placement.mob} overlaps another mob at ${x},${y}`);
        occupiedMobCells.add(index);
      }
    }
  }
  const expectedTreasure = treasureSelections(level);
  if (level.treasurePopulationTarget !== expectedTreasure.target) errors.push('treasure population target is inconsistent');
  if (level.roomTreasureCandidateCounts.some((count, room) => count !== expectedTreasure.candidatesByRoom[room])) errors.push('room treasure candidate counts are inconsistent');
  if (level.roomDistancesFromCriticalRoute.some((distance, room) => distance !== expectedTreasure.distances[room])) errors.push('room distances from critical route are inconsistent');
  if (JSON.stringify(level.treasurePlacements) !== JSON.stringify(expectedTreasure.placements)) errors.push('treasure placements are inconsistent');
  if (!(level.treasurePlacements ?? []).length) errors.push('level has no treasure eggs');
  if (!(level.treasurePlacements ?? []).some(placement => placement.contents === 'heart')) errors.push('level has no treasure-bearing egg');
  const occupiedTreasureCells = new Set();
  for (const placement of level.treasurePlacements ?? []) {
    if (!['heart', 'empty'].includes(placement.contents)) errors.push(`treasure egg in room ${placement.room} has unknown contents ${placement.contents}`);
    if (placement.width !== TREASURE_MANIFEST.width || placement.height !== TREASURE_MANIFEST.height) errors.push(`treasure egg metadata is inconsistent in room ${placement.room}`);
    if (placement.distanceFromCriticalRoute !== level.roomDistancesFromCriticalRoute[placement.room]) errors.push(`treasure egg has wrong route distance in room ${placement.room}`);
    for (let y = placement.y; y < placement.y + placement.height; y++) {
      for (let x = placement.x; x < placement.x + placement.width; x++) {
        const index = y * LEVEL_WIDTH + x;
        if (level.structuralTiles[index] !== 17) errors.push(`treasure egg body is obstructed at ${x},${y}`);
        if (level.placementReservationMask[index] & ENCOUNTER_BLOCKING_RESERVATIONS) errors.push(`treasure egg occupies protected cell ${x},${y}`);
        if (occupiedTreasureCells.has(index)) errors.push(`treasure eggs overlap at ${x},${y}`);
        occupiedTreasureCells.add(index);
      }
    }
  }
  for (let index = 0; index < level.tiles.length; index++) {
    if (!occupied.has(index) && level.tiles[index] !== level.structuralTiles[index]) errors.push(`composition changed unoccupied cell ${index % LEVEL_WIDTH},${Math.floor(index / LEVEL_WIDTH)}`);
    if (!wallpaperOccupied.has(index) && level.tiles[index] !== level.wallpaperSourceTiles[index]) errors.push(`wallpaper changed unoccupied cell ${index % LEVEL_WIDTH},${Math.floor(index / LEVEL_WIDTH)}`);
  }

  return { valid: errors.length === 0, errors };
}
