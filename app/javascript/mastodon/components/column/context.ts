import type { JSX } from 'react';
import { createContext, useContext } from 'react';

export const ColumnIndexContext = createContext(1);
export const useColumnIndexContext = () => useContext(ColumnIndexContext);

interface ColumnContext {
  scrollTop: () => void;
  isScrolledToTop: boolean;
  scrollSensor: JSX.Element | null;
}

export const ColumnContext = createContext<ColumnContext>({
  scrollTop: () => {
    // Implemented in index.tsx
  },
  isScrolledToTop: true,
  scrollSensor: null,
});

export const useColumn = () => useContext(ColumnContext);
