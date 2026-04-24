import { useCallback, useState } from 'react';

import classNames from 'classnames';

import { Blurhash } from './blurhash';

interface Props {
  alt: string;
  src: string;
  srcSet?: string;
  blurhash?: string;
  className?: string;
}

export const ServerHeroImage: React.FC<Props> = ({
  alt,
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
    <div className={classNames('image', { loaded }, className)}>
      {blurhash && <Blurhash hash={blurhash} className='image__preview' />}
      <img src={src} srcSet={srcSet} alt={alt} onLoad={handleLoad} />
    </div>
  );
};
