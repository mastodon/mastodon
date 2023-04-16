import React, { useCallback, useState } from 'react';

type Props = {
  src: string;
  key: string;
  alt?: string;
  lang?: string;
  width: number;
  height: number;
  onClick?: () => void;
}

export const GIFV: React.FC<Props> = ({
  src,
  alt,
  lang,
  width,
  height,
  onClick,
})=> {
  const [loading, setLoading] = useState(true);

  const handleLoadedData: React.ReactEventHandler<HTMLVideoElement> = useCallback(() => {
    setLoading(false);
  }, [setLoading]);

  const handleClick: React.MouseEventHandler = useCallback((e) => {
    if (onClick) {
      e.stopPropagation();
      onClick();
    }
  }, [onClick]);

  return (
    <div className='gifv' style={{ position: 'relative' }}>
      {loading && (
        <canvas
          width={width}
          height={height}
          role='button'
          tabIndex={0}
          aria-label={alt}
          title={alt}
          lang={lang}
          onClick={handleClick}
        />
      )}

      <video
        src={src}
        role='button'
        tabIndex={0}
        aria-label={alt}
        title={alt}
        lang={lang}
        muted
        loop
        autoPlay
        playsInline
        onClick={handleClick}
        onLoadedData={handleLoadedData}
        style={{ position: loading ? 'absolute' : 'static', top: 0, left: 0 }}
      />
    </div>
  );
};

export default GIFV;
