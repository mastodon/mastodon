import { useCallback, useState } from 'react';

import classNames from 'classnames';

import { AltTextBadge } from '../alt_text_badge';
import { Blurhash } from '../blurhash';

import classes from './styles.module.scss';

interface Props {
  withAltBadge?: boolean;
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
  withAltBadge,
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
      {withAltBadge && alt && (
        <AltTextBadge description={alt} className={classes.altBadge} />
      )}
    </div>
  );
};
