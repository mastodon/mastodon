import { useCallback, useRef } from 'react';

export const InterceptStatusClicks: React.FC<{
  onPreventedClick: (
    clickedArea: 'account' | 'post',
    event: React.MouseEvent,
  ) => void;
  children: React.ReactNode;
}> = ({ onPreventedClick, children }) => {
  const wrapperRef = useRef<HTMLDivElement>(null);

  const handleClick = useCallback(
    (e: React.MouseEvent) => {
      const clickTarget = e.target as Element;
      const allowedElementsSelector =
        '.video-player, .audio-player, .media-gallery, .content-warning';
      const allowedElements = wrapperRef.current?.querySelectorAll(
        allowedElementsSelector,
      );
      const isTargetClickAllowed =
        allowedElements &&
        Array.from(allowedElements).some((element) => {
          return clickTarget === element || element.contains(clickTarget);
        });

      if (!isTargetClickAllowed) {
        e.preventDefault();
        e.stopPropagation();

        const wasAccountAreaClicked = !!clickTarget.closest(
          'a.status__display-name',
        );

        onPreventedClick(wasAccountAreaClicked ? 'account' : 'post', e);
      }
    },
    [onPreventedClick],
  );

  return (
    <div ref={wrapperRef} onClickCapture={handleClick}>
      {children}
    </div>
  );
};
