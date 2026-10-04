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

export const RESERVATION_CRITICAL_ROUTE = 0x01;
export const RESERVATION_PORT = 0x02;
export const RESERVATION_WIDE_SEAM = 0x04;
export const RESERVATION_SPAWN = 0x08;
export const RESERVATION_EXIT = 0x10;
export const RESERVATION_LEDGE_CATCH = 0x20;

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
