import { useCallback, useState } from 'react';

export const useHovering = (animate?: boolean) => {
  const [hovering, setHovering] = useState<boolean>(animate ?? false);

  const handleMouseEnter = useCallback(() => {
    if (animate) return;
    setHovering(true);
  }, [animate]);

  const handleMouseLeave = useCallback(() => {
    if (animate) return;
    setHovering(false);
  }, [animate]);

  return { hovering, handleMouseEnter, handleMouseLeave };
};
