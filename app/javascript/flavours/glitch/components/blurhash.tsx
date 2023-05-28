import { useRef, useEffect } from 'react';
import * as React from 'react';

import { decode } from 'blurhash';

interface Props extends React.HTMLAttributes<HTMLCanvasElement> {
  hash: string;
  width?: number;
  height?: number;
  dummy?: boolean; // Whether dummy mode is enabled. If enabled, nothing is rendered and canvas left untouched
  children?: never;
}
const Blurhash: React.FC<Props> = ({
  hash,
  width = 32,
  height = width,
  dummy = false,
  ...canvasProps
}) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const canvas = canvasRef.current!;

    // eslint-disable-next-line no-self-assign
    canvas.width = canvas.width; // resets canvas

    if (dummy || !hash) return;

    try {
      const pixels = decode(hash, width, height);
      const ctx = canvas.getContext('2d');
      const imageData = new ImageData(pixels, width, height);

      ctx?.putImageData(imageData, 0, 0);
    } catch (err) {
      console.error('Blurhash decoding failure', { err, hash });
    }
  }, [dummy, hash, width, height]);

  return (
    <canvas {...canvasProps} ref={canvasRef} width={width} height={height} />
  );
};

const MemoizedBlurhash = React.memo(Blurhash);

export { MemoizedBlurhash as Blurhash };
