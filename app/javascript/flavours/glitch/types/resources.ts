import type { Record } from 'immutable';

type AccountValues = {
  id: number;
  avatar: string;
  avatar_static: string;
  [key: string]: any;
};

export type Account = Record<AccountValues>;
