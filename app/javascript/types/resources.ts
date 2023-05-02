import type { MastodonMap } from './util';

type AccountValues = {
  id: number;
  avatar: string;
  avatar_static: string;
  [key: string]: any;
};
export type Account = MastodonMap<AccountValues>;
