import type { LocationBase, ScrollPosition } from 'scroll-behavior';

const STATE_KEY_PREFIX = '@@scroll|';

interface LocationBaseWithKey extends LocationBase {
  key?: string;
}

/**
 * This module is part of our port of https://github.com/ytase/react-router-scroll/
 * and handles storing scroll positions in SessionStorage.
 * Stored positions (`[x, y]`) are keyed by the location key and an optional
 * `scrollKey` that's used for to track separately scrollable elements other
 * than the document body.
 */

export class SessionStorage {
  read(
    location: LocationBaseWithKey,
    key: string | null,
  ): ScrollPosition | null {
    const stateKey = this.getStateKey(location, key);

    try {
      const value = sessionStorage.getItem(stateKey);
      return value ? (JSON.parse(value) as ScrollPosition) : null;
    } catch {
      return null;
    }
  }

  save(location: LocationBaseWithKey, key: string | null, value: unknown) {
    const stateKey = this.getStateKey(location, key);
    const storedValue = JSON.stringify(value);

    try {
      sessionStorage.setItem(stateKey, storedValue);
    } catch {}
  }

  getStateKey(location: LocationBaseWithKey, key: string | null) {
    const locationKey = location.key;
    const stateKeyBase = `${STATE_KEY_PREFIX}${locationKey}`;
    return key == null ? stateKeyBase : `${stateKeyBase}|${key}`;
  }
}
