import type { RecentSearch } from './models/search';

export class Settings<T extends Record<string, unknown>> {
  keyBase: string | null;

  constructor(keyBase: string | null = null) {
    this.keyBase = keyBase;
  }

  private generateKey(id: string | number | symbol): string {
    const idStr = typeof id === 'string' ? id : String(id);
    return this.keyBase ? [this.keyBase, `id${idStr}`].join('.') : idStr;
  }

  set<K extends keyof T>(id: K, data: T[K]): T[K] | null {
    const key = this.generateKey(id);
    try {
      const encodedData = JSON.stringify(data);
      localStorage.setItem(key, encodedData);
      return data;
    } catch {
      return null;
    }
  }

  get<K extends keyof T>(id: K): T[K] | null {
    const key = this.generateKey(id);
    try {
      const rawData = localStorage.getItem(key);
      if (rawData === null) return null;
      return JSON.parse(rawData) as T[K];
    } catch {
      return null;
    }
  }

  remove<K extends keyof T>(id: K): T[K] | null {
    const data = this.get(id);
    if (data !== null) {
      const key = this.generateKey(id);
      try {
        localStorage.removeItem(key);
      } catch {
        // ignore if the key is not found
      }
    }
    return data;
  }
}

export const pushNotificationsSetting = new Settings<
  Record<string, { alerts: unknown }>
>('mastodon_push_notification_data');
export const tagHistory = new Settings<Record<string, string[]>>(
  'mastodon_tag_history',
);
export const bannerSettings = new Settings<Record<string, boolean>>(
  'mastodon_banner_settings',
);
export const searchHistory = new Settings<Record<string, RecentSearch[]>>(
  'mastodon_search_history',
);
export const playerSettings = new Settings<{ volume: number; muted: boolean }>(
  'mastodon_player',
);
export const wrapstodonSettings = new Settings<
  Record<string, { archetypeRevealed: boolean }>
>('wrapstodon');
