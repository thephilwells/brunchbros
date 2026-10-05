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

export function composeDiningRoom(level) {
  const composed = addDiningRoomFurniture(addDiningRoomBackground(addDiningRoomPlacementReservations(level)));
  composed.compositionValidation = validateDiningRoomComposition(composed);
  return composed;
}

export function validateDiningRoomComposition(level) {
  const errors = [...validateDiningRoomPlacementReservations(level).errors];
  if (!Array.isArray(level.structuralTiles) || level.structuralTiles.length !== LEVEL_WIDTH * LEVEL_HEIGHT) errors.push('structural tile snapshot must contain 1,280 cells');
  if (!Array.isArray(level.roomBackgroundCandidateCounts) || level.roomBackgroundCandidateCounts.length !== 16) errors.push('room background candidate counts must contain 16 entries');
  if (!Array.isArray(level.roomFurnitureCandidateCounts) || level.roomFurnitureCandidateCounts.length !== 16) errors.push('room furniture candidate counts must contain 16 entries');
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
  for (let index = 0; index < level.tiles.length; index++) {
    if (!occupied.has(index) && level.tiles[index] !== level.structuralTiles[index]) errors.push(`furniture changed unoccupied cell ${index % LEVEL_WIDTH},${Math.floor(index / LEVEL_WIDTH)}`);
  }

  return { valid: errors.length === 0, errors };
}
