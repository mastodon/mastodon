export interface MastodonMap<T> {
  get<K extends keyof T>(key: K): T[K];
  has<K extends keyof T>(key: K): boolean;
  set<K extends keyof T>(key: K, value: T[K]): this;
}

export type ValueOf<T> = T[keyof T];
