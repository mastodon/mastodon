import { useState, useCallback, useRef, useEffect } from 'react';

import classNames from 'classnames';

import { useSpring, animated, config, to } from '@react-spring/web';
import { createUseGesture, dragAction, pinchAction } from '@use-gesture/react';

import { Blurhash } from 'mastodon/components/blurhash';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';

const MIN_SCALE = 1;
const MAX_SCALE = 4;
const DOUBLE_CLICK_THRESHOLD = 250;

interface ZoomMatrix {
  containerWidth: number;
  containerHeight: number;
  imageWidth: number;
  imageHeight: number;
  initialScale: number;
}

const createZoomMatrix = (
  container: HTMLElement,
  image: HTMLImageElement,
  fullWidth: number,
  fullHeight: number,
): ZoomMatrix => {
  const { clientWidth, clientHeight } = container;
  const { offsetWidth, offsetHeight } = image;

  const type =
    fullWidth / fullHeight < clientWidth / clientHeight ? 'width' : 'height';

  const initialScale =
    type === 'width'
      ? Math.min(clientWidth, fullWidth) / offsetWidth
      : Math.min(clientHeight, fullHeight) / offsetHeight;

  return {
    containerWidth: clientWidth,
    containerHeight: clientHeight,
    imageWidth: offsetWidth,
    imageHeight: offsetHeight,
    initialScale,
  };
};

const useGesture = createUseGesture([dragAction, pinchAction]);

const getBounds = (zoomMatrix: ZoomMatrix | null, scale: number) => {
  if (!zoomMatrix || scale === MIN_SCALE) {
    return {
      left: -Infinity,
      right: Infinity,
      top: -Infinity,
      bottom: Infinity,
    };
  }

  const { containerWidth, containerHeight, imageWidth, imageHeight } =
    zoomMatrix;

  const bounds = {
    left: -Math.max(imageWidth * scale - containerWidth, 0) / 2,
    right: Math.max(imageWidth * scale - containerWidth, 0) / 2,
    top: -Math.max(imageHeight * scale - containerHeight, 0) / 2,
    bottom: Math.max(imageHeight * scale - containerHeight, 0) / 2,
  };

  return bounds;
};

interface ZoomableImageProps {
  alt?: string;
  lang?: string;
  src: string;
  width: number;
  height: number;
  onClick?: () => void;
  onDoubleClick?: () => void;
  onClose?: () => void;
  onZoomChange?: (zoomedIn: boolean) => void;
  zoomedIn?: boolean;
  blurhash?: string;
}

export const ZoomableImage: React.FC<ZoomableImageProps> = ({
  alt = '',
  lang = '',
  src,
  width,
  height,
  onClick,
  onDoubleClick,
  onClose,
  onZoomChange,
  zoomedIn,
  blurhash,
}) => {
  useEffect(() => {
    const handler = (e: Event) => {
      e.preventDefault();
    };

    document.addEventListener('gesturestart', handler);
    document.addEventListener('gesturechange', handler);
    document.addEventListener('gestureend', handler);

    return () => {
      document.removeEventListener('gesturestart', handler);
      document.removeEventListener('gesturechange', handler);
      document.removeEventListener('gestureend', handler);
    };
  }, []);

  const [dragging, setDragging] = useState(false);
  const [loaded, setLoaded] = useState(false);
  const [error, setError] = useState(false);

  const containerRef = useRef<HTMLDivElement>(null);
  const imageRef = useRef<HTMLImageElement>(null);
  const doubleClickTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>();
  const zoomMatrixRef = useRef<ZoomMatrix | null>(null);

  const [style, api] = useSpring(() => ({
    x: 0,
    y: 0,
    scale: 1,
    onRest: {
      scale({ value }) {
        if (!onZoomChange) {
          return;
        }
        if (value === MIN_SCALE) {
          onZoomChange(false);
        } else {
          onZoomChange(true);
        }
      },
    },
  }));

  useGesture(
    {
      onDrag({
        pinching,
        cancel,
        active,
        last,
        offset: [x, y],
        velocity: [, vy],
        direction: [, dy],
        tap,
      }) {
        if (tap) {
          if (!doubleClickTimeoutRef.current) {
            doubleClickTimeoutRef.current = setTimeout(() => {
              onClick?.();
              doubleClickTimeoutRef.current = null;
            }, DOUBLE_CLICK_THRESHOLD);
          } else {
            clearTimeout(doubleClickTimeoutRef.current);
            doubleClickTimeoutRef.current = null;
            onDoubleClick?.();
          }

          return;
        }

        if (!zoomedIn) {
          // Swipe up/down to dismiss parent
          if (last) {
            if ((vy > 0.5 && dy !== 0) || Math.abs(y) > 150) {
              onClose?.();
            }

            void api.start({ y: 0, config: config.wobbly });
            return;
          } else if (dy !== 0) {
            void api.start({ y, immediate: true });
            return;
          }

          cancel();
          return;
        }

        if (pinching) {
          cancel();
          return;
        }

        if (active) {
          setDragging(true);
        } else {
          setDragging(false);
        }

        void api.start({ x, y });
      },

      onPinch({ origin: [ox, oy], first, movement: [ms], offset: [s], memo }) {
        if (!imageRef.current) {
          return;
        }

        if (first) {
          const { width, height, x, y } =
            imageRef.current.getBoundingClientRect();
          const tx = ox - (x + width / 2);
          const ty = oy - (y + height / 2);

          memo = [style.x.get(), style.y.get(), tx, ty];
        }

        const x = memo[0] - (ms - 1) * memo[2]; // eslint-disable-line @typescript-eslint/no-unsafe-member-access
        const y = memo[1] - (ms - 1) * memo[3]; // eslint-disable-line @typescript-eslint/no-unsafe-member-access

        void api.start({ scale: s, x, y });

        return memo as [number, number, number, number];
      },
    },
    {
      target: imageRef,
      drag: {
        from: () => [style.x.get(), style.y.get()],
        filterTaps: true,
        bounds: () => getBounds(zoomMatrixRef.current, style.scale.get()),
        rubberband: true,
      },
      pinch: {
        scaleBounds: {
          min: MIN_SCALE,
          max: MAX_SCALE,
        },
        rubberband: true,
      },
    },
  );

  useEffect(() => {
    if (!loaded || !containerRef.current || !imageRef.current) {
      return;
    }

    zoomMatrixRef.current = createZoomMatrix(
      containerRef.current,
      imageRef.current,
      width,
      height,
    );

    if (!zoomedIn) {
      void api.start({ scale: MIN_SCALE, x: 0, y: 0 });
    } else if (style.scale.get() === MIN_SCALE) {
      void api.start({ scale: zoomMatrixRef.current.initialScale, x: 0, y: 0 });
    }
  }, [api, style.scale, zoomedIn, width, height, loaded]);

  const handleClick = useCallback((e: React.MouseEvent) => {
    // This handler exists to cancel the onClick handler on the media modal which would
    // otherwise close the modal. It cannot be used for actual click handling because
    // we don't know if the user is about to pan the image or not.

    e.preventDefault();
    e.stopPropagation();
  }, []);

  const handleLoad = useCallback(() => {
    setLoaded(true);
  }, [setLoaded]);

  const handleError = useCallback(() => {
    setError(true);
  }, [setError]);

  // Convert the default style transform to a matrix transform to work around
  // Safari bug https://github.com/mastodon/mastodon/issues/35042
  const transform = to(
    [style.scale, style.x, style.y],
    (s, x, y) => `matrix(${s}, 0, 0, ${s}, ${x}, ${y})`,
  );

  return (
    <div
      className={classNames('zoomable-image', {
        'zoomable-image--zoomed-in': zoomedIn,
        'zoomable-image--error': error,
        'zoomable-image--dragging': dragging,
      })}
      ref={containerRef}
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

      <animated.img
        style={{ transform }}
        ref={imageRef}
        alt={alt}
        lang={lang}
        src={src}
        width={width}
        height={height}
        draggable={false}
        onLoad={handleLoad}
        onError={handleError}
        onClickCapture={handleClick}
      />

      {!loaded && !error && <LoadingIndicator />}
    </div>
  );
};
