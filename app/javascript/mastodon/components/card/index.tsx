import type React from 'react';
import { createContext, use, useId, useState } from 'react';

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

interface CardContext {
  id: string;
  registerImage?: (ref: HTMLImageElement) => void;
}

const CardContext = createContext<CardContext>({ id: '' });

export const Card = <As extends React.ElementType>({
  as: asComp,
  children,
  className,
  onDelete,
  ...props
}: CardProps<As>) => {
  const Comp = asComp ?? 'div';

  const id = useId();
  const [hasImage, registerImage] = useState<HTMLImageElement | null>(null);

  // Disable the button if this is an interactive element, including a Link component.
  const hideButton =
    !onDelete || asComp === 'a' || asComp === 'button' || 'to' in props;

  return (
    <Comp {...props} className={classNames(className, classes.root)}>
      <CardContext.Provider value={{ id, registerImage }}>
        {children}
      </CardContext.Provider>

      {!hideButton && (
        <IconButton
          variant='solid'
          icon={TrashIcon}
          onClick={onDelete}
          color='destructive'
          className={classes.delete}
          size={hasImage ? 'sm' : 'xs'}
          aria-describedby={`${id}_title`}
          data-color-scheme={hasImage ? 'dark' : undefined}
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
  const { id } = use(CardContext);

  return (
    <div className={classes.title}>
      {imageSrc && (
        <img src={imageSrc} alt={imageAlt} className={classes.titleImage} />
      )}

      <span id={`${id}_title`}>{children}</span>

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
  const { registerImage } = use(CardContext);

  return (
    <div className={classes.image} ref={registerImage}>
      <img {...props} alt={alt} />
    </div>
  );
};
