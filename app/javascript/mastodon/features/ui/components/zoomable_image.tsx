import { useState, useCallback, useRef, useEffect } from 'react';

import classNames from 'classnames';

import { Blurhash } from 'mastodon/components/blurhash';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';

const MIN_SCALE = 1;
const MAX_SCALE = 4;
const MAX_CLICK_DELTA = 5;
const DOUBLE_CLICK_THRESHOLD = 300;

const getMidpoint = (p1: Touch, p2: Touch) => ({
  x: (p1.clientX + p2.clientX) / 2,
  y: (p1.clientY + p2.clientY) / 2,
});

const getDistance = (p1: Touch, p2: Touch) =>
  Math.sqrt(
    Math.pow(p1.clientX - p2.clientX, 2) + Math.pow(p1.clientY - p2.clientY, 2),
  );

const clamp = (min: number, max: number, value: number) =>
  Math.min(max, Math.max(min, value));

interface ZoomMatrix {
  type: 'width' | 'height';
  fullScreen: boolean;
  rate: number;
  clientWidth: number;
  clientHeight: number;
  offsetWidth: number;
  offsetHeight: number;
  scrollTop: number;
  scrollLeft: number;
  translateX: number;
  translateY: number;
}

interface Position {
  x: number;
  y: number;
}

interface DragPosition extends Position {
  top: number;
  left: number;
}

const initZoomMatrix = ({
  width,
  height,
  clientWidth,
  clientHeight,
  offsetWidth,
  offsetHeight,
}: {
  width: number;
  height: number;
  clientWidth: number;
  clientHeight: number;
  offsetWidth: number;
  offsetHeight: number;
}): ZoomMatrix => {
  const type = width / height < clientWidth / clientHeight ? 'width' : 'height';
  const fullScreen =
    type === 'width' ? width > clientWidth : height > clientHeight;
  const rate =
    type === 'width'
      ? Math.min(clientWidth, width) / offsetWidth
      : Math.min(clientHeight, height) / offsetHeight;
  const scrollTop =
    type === 'width'
      ? (clientHeight - offsetHeight) / 2
      : (clientHeight - offsetHeight) / 2;
  const scrollLeft = (clientWidth - offsetWidth) / 2;
  const translateX = type === 'width' ? (width - offsetWidth) / (2 * rate) : 0;
  const translateY =
    type === 'height' ? (height - offsetHeight) / (2 * rate) : 0;

  return {
    type: type,
    fullScreen: fullScreen,
    rate: rate,
    clientWidth: clientWidth,
    clientHeight: clientHeight,
    offsetWidth: offsetWidth,
    offsetHeight: offsetHeight,
    scrollTop: scrollTop,
    scrollLeft: scrollLeft,
    translateX: translateX,
    translateY: translateY,
  };
};

export const ZoomableImage: React.FC<{
  alt?: string;
  lang?: string;
  src: string;
  width: number;
  height: number;
  onClick?: () => void;
  onDoubleClick?: () => void;
  onZoomChange?: (zoomedIn: boolean) => void;
  zoomedIn?: boolean;
  blurhash?: string;
}> = ({
  alt = '',
  lang = '',
  src,
  width,
  height,
  onClick,
  onDoubleClick,
  onZoomChange,
  zoomedIn,
  blurhash,
}) => {
  const [scale, setScale] = useState(MIN_SCALE);
  const [dragging, setDragging] = useState(false);
  const [loaded, setLoaded] = useState(false);
  const [error, setError] = useState(false);
  const [lockTranslate, setLockTranslate] = useState<Position>({ x: 0, y: 0 });

  const containerRef = useRef<HTMLDivElement>(null);
  const imageRef = useRef<HTMLImageElement>(null);

  const zoomMatrix = useRef<ZoomMatrix>({
    type: 'width',
    fullScreen: false,
    rate: MIN_SCALE,
    clientWidth: 0,
    clientHeight: 0,
    offsetWidth: 0,
    offsetHeight: 0,
    scrollTop: 0,
    scrollLeft: 0,
    translateX: 0,
    translateY: 0,
  });
  const dragPosition = useRef<DragPosition>({
    top: 0,
    left: 0,
    x: 0,
    y: 0,
  });
  const lockScroll = useRef<Position>({ x: 0, y: 0 });
  const lastDistance = useRef(0);
  const doubleClickTimeout = useRef<ReturnType<typeof setTimeout> | null>();

  useEffect(() => {
    if (!loaded) {
      return;
    }

    zoomMatrix.current = initZoomMatrix({
      width,
      height,
      clientWidth: containerRef.current?.clientWidth ?? 0,
      clientHeight: containerRef.current?.clientHeight ?? 0,
      offsetWidth: imageRef.current?.offsetWidth ?? 0,
      offsetHeight: imageRef.current?.offsetHeight ?? 0,
    });

    if (!zoomedIn) {
      setScale(MIN_SCALE);

      lockScroll.current = { x: 0, y: 0 };

      setLockTranslate({ x: 0, y: 0 });

      // Setting scrollLeft/scrollTop doesn't work without the delay
      setTimeout(() => {
        if (containerRef.current) {
          containerRef.current.scrollLeft = 0;
          containerRef.current.scrollTop = 0;
        }
      }, 0);
    } else {
      setScale(zoomMatrix.current.rate);

      lockScroll.current = {
        x: zoomMatrix.current.scrollLeft,
        y: zoomMatrix.current.scrollTop,
      };

      setLockTranslate({
        x: zoomMatrix.current.fullScreen ? 0 : zoomMatrix.current.translateX,
        y: zoomMatrix.current.fullScreen ? 0 : zoomMatrix.current.translateY,
      });

      // Setting scrollLeft/scrollTop doesn't work without the delay
      setTimeout(() => {
        if (containerRef.current) {
          containerRef.current.scrollLeft = zoomMatrix.current.scrollLeft;
          containerRef.current.scrollTop = zoomMatrix.current.scrollTop;
        }
      }, 0);
    }
  }, [setScale, setLockTranslate, zoomedIn, width, height, loaded]);

  useEffect(() => {
    if (scale === MIN_SCALE) {
      onZoomChange?.(false);
    } else if (scale >= zoomMatrix.current.rate) {
      onZoomChange?.(true);
    }
  }, [scale, onZoomChange]);

  const handleTouchStart = useCallback(
    (e: TouchEvent) => {
      // Pan
      if (e.touches.length === 1 && scale !== MIN_SCALE) {
        e.preventDefault();
        e.stopPropagation();

        const p1 = e.touches[0];

        if (!containerRef.current || !p1) {
          return;
        }

        dragPosition.current = {
          left: containerRef.current.scrollLeft,
          top: containerRef.current.scrollTop,
          // Get the current finger position
          x: p1.clientX,
          y: p1.clientY,
        };

        setDragging(true);
      }

      // Pinch to zoom
      if (e.touches.length === 2) {
        e.preventDefault();
        e.stopPropagation();

        const p1 = e.touches[0];
        const p2 = e.touches[1];

        if (p1 && p2) {
          lastDistance.current = getDistance(p1, p2);
        }
      }
    },
    [setDragging, scale],
  );

  const handleTouchMove = useCallback(
    (e: TouchEvent) => {
      if (!containerRef.current) {
        return;
      }

      // Pan
      if (e.touches.length === 1 && dragging) {
        e.preventDefault();
        e.stopPropagation();

        const { left, top, x, y } = dragPosition.current;
        const p1 = e.touches[0];

        if (!p1) {
          return;
        }

        const dx = p1.clientX - x;
        const dy = p1.clientY - y;

        containerRef.current.scrollLeft = Math.max(
          left - dx,
          lockScroll.current.x,
        );
        containerRef.current.scrollTop = Math.max(
          top - dy,
          lockScroll.current.y,
        );
      }

      // Pinch to zoom
      if (e.touches.length === 2) {
        e.preventDefault();
        e.stopPropagation();

        const { scrollTop, scrollLeft } = containerRef.current;

        const p1 = e.touches[0];
        const p2 = e.touches[1];

        if (!p1 || !p2) {
          return;
        }

        const distance = getDistance(p1, p2);
        const midpoint = getMidpoint(p1, p2);
        const _MAX_SCALE = Math.max(MAX_SCALE, zoomMatrix.current.rate);
        const nextScale = clamp(
          MIN_SCALE,
          _MAX_SCALE,
          (scale * distance) / lastDistance.current,
        );

        // math memo:
        // x = (scrollLeft + midpoint.x) / scrollWidth
        // x' = (nextScrollLeft + midpoint.x) / nextScrollWidth
        // scrollWidth = clientWidth * scale
        // scrollWidth' = clientWidth * nextScale
        // Solve x = x' for nextScrollLeft
        const nextScrollLeft =
          ((scrollLeft + midpoint.x) * nextScale) / scale - midpoint.x;
        const nextScrollTop =
          ((scrollTop + midpoint.y) * nextScale) / scale - midpoint.y;

        containerRef.current.scrollLeft = nextScrollLeft;
        containerRef.current.scrollTop = nextScrollTop;

        setScale(nextScale);

        if (nextScale < zoomMatrix.current.rate) {
          setLockTranslate({
            x: zoomMatrix.current.fullScreen
              ? 0
              : zoomMatrix.current.translateX *
                ((nextScale - MIN_SCALE) /
                  (zoomMatrix.current.rate - MIN_SCALE)),
            y: zoomMatrix.current.fullScreen
              ? 0
              : zoomMatrix.current.translateY *
                ((nextScale - MIN_SCALE) /
                  (zoomMatrix.current.rate - MIN_SCALE)),
          });
        }

        lastDistance.current = distance;
      }
    },
    [setLockTranslate, setScale, dragging, scale],
  );

  const handleTouchEnd = useCallback(
    (e: TouchEvent) => {
      if (dragging) {
        e.preventDefault();
        e.stopPropagation();

        const { x, y } = dragPosition.current;
        const p1 = e.changedTouches[0];

        if (!p1) {
          return;
        }

        const deltaX = Math.abs(p1.clientX - x);
        const deltaY = Math.abs(p1.clientY - y);

        if (deltaX + deltaY < MAX_CLICK_DELTA) {
          if (!doubleClickTimeout.current) {
            doubleClickTimeout.current = setTimeout(() => {
              onClick?.();
              doubleClickTimeout.current = null;
            }, DOUBLE_CLICK_THRESHOLD);
          } else {
            clearTimeout(doubleClickTimeout.current);
            doubleClickTimeout.current = null;
            onDoubleClick?.();
          }
        }

        setDragging(false);
      }
    },
    [dragging, setDragging, onClick, onDoubleClick],
  );

  useEffect(() => {
    if (!containerRef.current) {
      return;
    }

    const element = containerRef.current;

    element.addEventListener('touchstart', handleTouchStart, {
      passive: false,
    });
    element.addEventListener('touchmove', handleTouchMove, {
      passive: false,
    });
    element.addEventListener('touchend', handleTouchEnd, {
      passive: false,
    });

    return () => {
      element.removeEventListener('touchstart', handleTouchStart);
      element.removeEventListener('touchmove', handleTouchMove);
      element.removeEventListener('touchend', handleTouchEnd);
    };
  }, [handleTouchStart, handleTouchMove, handleTouchEnd]);

  const handleClick = useCallback((e: React.MouseEvent) => {
    // This handler exists to cancel the onClick handler on the media modal which would
    // otherwise close the modal. It cannot be used for actual click handling because
    // we don't know if the user is about to pan the image or not.

    e.preventDefault();
    e.stopPropagation();
  }, []);

  const handleMouseDown = useCallback(
    (e: React.MouseEvent) => {
      if (e.button !== 0) {
        return;
      }

      e.preventDefault();
      e.stopPropagation();

      if (!containerRef.current) {
        return;
      }

      dragPosition.current = {
        left: containerRef.current.scrollLeft,
        top: containerRef.current.scrollTop,
        // Get the current mouse position
        x: e.clientX,
        y: e.clientY,
      };

      setDragging(true);
    },
    [setDragging],
  );

  const handleMouseMove = useCallback(
    (e: React.MouseEvent) => {
      if (!dragging) {
        return;
      }

      const { left, top, x, y } = dragPosition.current;

      const dx = e.clientX - x;
      const dy = e.clientY - y;

      if (containerRef.current) {
        containerRef.current.scrollLeft = Math.max(
          left - dx,
          lockScroll.current.x,
        );
        containerRef.current.scrollTop = Math.max(
          top - dy,
          lockScroll.current.y,
        );
      }
    },
    [dragging],
  );

  const handleMouseUp = useCallback(
    (e: React.MouseEvent) => {
      if (e.button !== 0) {
        return;
      }

      e.preventDefault();
      e.stopPropagation();

      const { x, y } = dragPosition.current;
      const deltaX = Math.abs(e.clientX - x);
      const deltaY = Math.abs(e.clientY - y);

      if (deltaX + deltaY < MAX_CLICK_DELTA) {
        if (!doubleClickTimeout.current) {
          doubleClickTimeout.current = setTimeout(() => {
            onClick?.();
            doubleClickTimeout.current = null;
          }, DOUBLE_CLICK_THRESHOLD);
        } else {
          clearTimeout(doubleClickTimeout.current);
          doubleClickTimeout.current = null;
          onDoubleClick?.();
        }
      }

      if (!dragging) {
        return;
      }

      setDragging(false);
    },
    [onClick, onDoubleClick, dragging, setDragging],
  );

  const handleLoad = useCallback(() => {
    setLoaded(true);
  }, [setLoaded]);

  const handleError = useCallback(() => {
    setError(true);
  }, [setError]);

  const cursor =
    scale === MIN_SCALE ? undefined : dragging ? 'grabbing' : 'grab';

  return (
    <div
      className={classNames('zoomable-image', {
        'zoomable-image--zoomed-in': scale !== MIN_SCALE,
        'zoomable-image--error': error,
      })}
      ref={containerRef}
      style={{ cursor, userSelect: 'none' }}
    >
      {!loaded && blurhash && (
        <div
          className='zoomable-image__preview'
          style={{
            aspectRatio: `${width}/${height}`,
            height: `min(${height}px, 100%)`,
          }}
        >
          <Blurhash hash={blurhash} />
        </div>
      )}

      <img
        role='presentation'
        ref={imageRef}
        alt={alt}
        title={alt}
        lang={lang}
        src={src}
        width={width}
        height={height}
        style={{
          transform: `scale(${scale}) translate(-${lockTranslate.x}px, -${lockTranslate.y}px)`,
          transformOrigin: '0 0',
        }}
        draggable={false}
        onLoad={handleLoad}
        onError={handleError}
        onClickCapture={handleClick}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
      />

      {!loaded && !error && <LoadingIndicator />}
    </div>
  );
};
