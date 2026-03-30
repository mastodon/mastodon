export function isKeyboardEvent(event: Event): event is KeyboardEvent {
  return 'key' in event;
}

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
