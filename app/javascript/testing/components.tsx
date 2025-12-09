import type { FC, ReactNode } from 'react';
import { useState } from 'react';

export const Awaited: FC<{
  cb: () => Promise<void>;
  onLoaded?: () => void;
  children: ReactNode;
}> = ({ cb, children, onLoaded }) => {
  const [loaded, setLoaded] = useState(false);

  if (!loaded) {
    void cb().then(() => {
      setLoaded(true);
      onLoaded?.();
    });
    return null;
  }

  return children;
};
