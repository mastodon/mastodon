import { useCallback, useState, forwardRef } from 'react';

interface Props {
  src: string;
  alt?: string;
  lang?: string;
  width?: number;
  height?: number;
  onClick?: React.MouseEventHandler;
  onMouseDown?: React.MouseEventHandler;
  onTouchStart?: React.TouchEventHandler;
}

export const GIFV = forwardRef<HTMLVideoElement, Props>(
  (
    { src, alt, lang, width, height, onClick, onMouseDown, onTouchStart },
    ref,
  ) => {
    const [loading, setLoading] = useState(true);

    const handleLoadedData = useCallback(() => {
      setLoading(false);
    }, [setLoading]);

    const handleClick = useCallback(
      (e: React.MouseEvent) => {
        e.stopPropagation();
        onClick?.(e);
      },
      [onClick],
    );

    return (
      <div className='gifv'>
        {loading && (
          <canvas
            role='button'
            tabIndex={0}
            aria-label={alt}
            lang={lang}
            onClick={handleClick}
          />
        )}

        <video
          ref={ref}
          src={src}
          role='button'
          tabIndex={0}
          aria-label={alt}
          lang={lang}
          width={width}
          height={height}
          muted
          loop
          autoPlay
          playsInline
          onClick={handleClick}
          onLoadedData={handleLoadedData}
          onMouseDown={onMouseDown}
          onTouchStart={onTouchStart}
        />
      </div>
    );
  },
);

GIFV.displayName = 'GIFV';
