import React, { useCallback, useState } from 'react';
import { Blurhash } from './blurhash';
import classNames from 'classnames';

type Props = {
  src: string;
  srcSet?: string;
  blurhash?: string;
  className?: string;
};

export const Image: React.FC<Props> = ({
  src,
  srcSet,
  blurhash,
  className,
}) => {
  const [loaded, setLoaded] = useState(false);

  const handleLoad = useCallback(() => {
    setLoaded(true);
  }, [setLoaded]);

  return (
    <div
      className={classNames('image', { loaded }, className)}
      role='presentation'
    >
      {blurhash && <Blurhash hash={blurhash} className='image__preview' />}
      <img src={src} srcSet={srcSet} alt='' onLoad={handleLoad} />
    </div>
  );
};
