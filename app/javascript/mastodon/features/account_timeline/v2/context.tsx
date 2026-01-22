import type { Dispatch, SetStateAction } from 'react';
import { createContext } from 'react';

interface FilterContextValue {
  boosts: boolean;
  replies: boolean;
  setBoosts: Dispatch<SetStateAction<boolean>>;
  setReplies: Dispatch<SetStateAction<boolean>>;
}

export const FilterContext = createContext<FilterContextValue>({
  boosts: false,
  replies: false,
  setBoosts() {
    throw new Error('setBoosts function must be overridden');
  },
  setReplies() {
    throw new Error('setReplies function must be overridden');
  },
});
