export type ValidObjectKey = string | number | symbol;
export type RecordObject = Record<ValidObjectKey, unknown>;

export function isRecord(value: unknown): value is RecordObject {
  return typeof value === 'object' && value !== null;
}
