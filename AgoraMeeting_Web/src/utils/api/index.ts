import uuidv4 from 'uuid/v4'
import {UUIDKeyIdentifier } from '@/utils/config'

export { WhiteboardAPI } from './whiteboard-api'

const storage = sessionStorage

export function genUUID (): string {
  let uuid = storage.getItem(UUIDKeyIdentifier);
  if (uuid) {
    return uuid;
  }
  uuid = uuidv4();
  storage.setItem(UUIDKeyIdentifier, uuid);
  return uuid;
}