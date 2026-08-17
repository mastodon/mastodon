export type ErrorToken =
  | 'ERR_TAKEN'
  | 'ERR_INVALID'
  | 'ERR_BLOCKED'
  | 'ERR_RESERVED'
  | 'ERR_TOO_MANY'
  | 'ERR_MALFORMED'
  | 'ERR_UNUSABLE'
  | 'ERR_TOO_SOON'
  | 'ERR_BELOW_LIMIT'
  | 'ERR_UNREACHABLE'
  | 'ERR_ELEVATED';

export interface ValidationError {
  error: ErrorToken;
  description: string;
}

export interface ValidationErrorResponse {
  error: string;
  details: Record<string, ValidationError[]>;
}
