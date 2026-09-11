export function isKeyboardEvent(event: Event): event is KeyboardEvent {
  return 'key' in event;
}

/**
 * Normalises key values to consistent lowercase strings
 */
export function normalizeKey(key: string): string {
  const lowerKey = key.toLowerCase();

  switch (lowerKey) {
    case ' ':
    case 'spacebar': // for older browsers
      return 'space';

    case 'arrowup':
      return 'up';
    case 'arrowdown':
      return 'down';
    case 'arrowleft':
      return 'left';
    case 'arrowright':
      return 'right';

    case 'esc':
    case 'escape':
      return 'escape';

    default:
      return lowerKey;
  }
}

/**
 * Compare whether a key matches an `event.code` value,
 * with support for single-letter keys (which are otherwise
 * represented with a `Key` prefix, e.g. `m` is `KeyM`).
 */
export function matchesKeyCode(key: string, code: string) {
  if (key.length === 1) {
    return code === `Key${key.toUpperCase()}`;
  } else {
    return code.toLowerCase() === key.toLowerCase();
  }
}
