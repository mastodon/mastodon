import { useRef, useCallback } from 'react';

type Position = [number, number];

export const useSelectableClick = (
  onClick: React.MouseEventHandler,
  maxDelta = 5,
) => {
  const clickPositionRef = useRef<Position | null>(null);

  const handleMouseDown = useCallback((e: React.MouseEvent) => {
    clickPositionRef.current = [e.clientX, e.clientY];
  }, []);

  const handleMouseUp = useCallback(
    (e: React.MouseEvent) => {
      if (!clickPositionRef.current) {
        return;
      }

      const [startX, startY] = clickPositionRef.current;
      const [deltaX, deltaY] = [
        Math.abs(e.clientX - startX),
        Math.abs(e.clientY - startY),
      ];

      let element: EventTarget | null = e.target;

      while (element && element instanceof HTMLElement) {
        if (
          element.localName === 'button' ||
          element.localName === 'a' ||
          element.localName === 'label'
        ) {
          return;
        }

        element = element.parentNode;
      }

      if (
        deltaX + deltaY < maxDelta &&
        (e.button === 0 || e.button === 1) &&
        e.detail >= 1
      ) {
        onClick(e);
      }

      clickPositionRef.current = null;
    },
    [maxDelta, onClick],
  );

  return [handleMouseDown, handleMouseUp] as const;
};
