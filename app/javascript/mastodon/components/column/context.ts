import { createContext, useContext } from 'react';

export const ColumnIndexContext = createContext(1);
export const useColumnIndexContext = () => useContext(ColumnIndexContext);

export const ColumnContext = createContext({
  scrollTop: () => {
    // Implemented in index.tsx
  },
});

export const useColumn = () => useContext(ColumnContext);
