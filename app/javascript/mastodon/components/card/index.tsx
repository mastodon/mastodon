import type React from 'react';
import { createContext, use, useEffect, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { TrashIcon } from '@phosphor-icons/react';

import type { PolymorphicProps } from '@/types/polymorphic';

import { IconButton } from '../button/redesign';
import { RelativeTimestamp } from '../relative_timestamp';

import classes from './styles.module.scss';

type CardProps<As extends React.ElementType> = PolymorphicProps<
  {
    children: React.ReactNode;
    className?: string;
    onDelete?: React.MouseEventHandler<HTMLButtonElement>;
  },
  As
>;

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const CardContext = createContext((_value: boolean) => {
  // empty
});

export const Card = <As extends React.ElementType>({
  as: asComp,
  children,
  className,
  onDelete,
  ...props
}: CardProps<As>) => {
  const Comp = asComp ?? 'div';

  const [hasImage, registerImage] = useState(false);

  return (
    <Comp {...props} className={classNames(className, classes.root)}>
      <CardContext.Provider value={registerImage}>
        {children}
      </CardContext.Provider>

      {onDelete && (
        <IconButton
          icon={TrashIcon}
          onClick={onDelete}
          size={hasImage ? 'sm' : 'xs'}
          variant={hasImage ? 'solid' : 'ghost'}
          color='destructive'
          className={classes.delete}
        >
          <FormattedMessage id='card.delete' defaultMessage='Remove this' />
        </IconButton>
      )}
    </Comp>
  );
};

interface CardTitleProps {
  children: React.ReactNode;
  imageSrc?: string;
  imageAlt?: string;
  timestamp?: string;
}

export const CardTitle: React.FC<CardTitleProps> = ({
  children,
  imageSrc,
  imageAlt = '',
  timestamp,
}) => {
  return (
    <div className={classes.title}>
      {imageSrc && (
        <img src={imageSrc} alt={imageAlt} className={classes.titleImage} />
      )}

      {children}

      {timestamp && (
        // eslint-disable-next-line no-restricted-syntax -- Allow &bull;
        <span>
          &nbsp;&bull;&nbsp;
          <RelativeTimestamp timestamp={timestamp} />
        </span>
      )}
    </div>
  );
};

type CardBodyProps<As extends React.ElementType> = PolymorphicProps<
  {
    children: React.ReactNode;
    className?: string;
    noClamp?: boolean;
  },
  As
>;

export const CardBody = <As extends React.ElementType>({
  as: asComp,
  children,
  className,
  noClamp,
  ...props
}: CardBodyProps<As>) => {
  const Comp = asComp ?? 'div';
  return (
    <Comp
      {...props}
      className={classNames(className, classes.body, !noClamp && classes.clamp)}
    >
      {children}
    </Comp>
  );
};

export const CardImage: React.FC<React.ComponentPropsWithRef<'img'>> = ({
  alt,
  ...props
}) => {
  const registerImage = use(CardContext);
  useEffect(() => {
    registerImage(true);
    return () => {
      registerImage(false);
    };
  }, [registerImage]);

  return (
    <div className={classes.image}>
      <img {...props} alt={alt} />
    </div>
  );
};
