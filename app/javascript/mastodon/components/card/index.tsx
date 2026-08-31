import type React from 'react';
import { createContext, use, useId } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { TrashIcon } from '@phosphor-icons/react';

import type { PolymorphicProps } from '@/types/polymorphic';

import { IconButton } from '../button/redesign';

import classes from './styles.module.scss';

type CardProps<As extends React.ElementType> = PolymorphicProps<
  {
    children: React.ReactNode;
    className?: string;
    image?: React.ReactNode;
    onDelete?: React.MouseEventHandler<HTMLButtonElement>;
  },
  As
>;

interface CardContext {
  id: string;
}

const CardContext = createContext<CardContext>({ id: '' });

export const Card = <As extends React.ElementType = 'div'>({
  as: asComp,
  children,
  className,
  image,
  onDelete,
  ...props
}: CardProps<As>) => {
  const Comp = asComp ?? 'div';

  const id = useId();

  // Disable the button if this is an interactive element, including a Link component.
  const hideButton =
    !onDelete || asComp === 'a' || asComp === 'button' || 'to' in props;

  const imageComp =
    typeof image === 'string' ? (
      <img src={image} alt='' className={classes.image} />
    ) : (
      image && <div className={classes.image}>{image}</div>
    );

  return (
    <Comp {...props} className={classNames(className, classes.root)}>
      <CardContext.Provider value={{ id }}>{children}</CardContext.Provider>

      {imageComp}

      {!hideButton && (
        <IconButton
          size='sm'
          icon={TrashIcon}
          onClick={onDelete}
          color='destructive'
          className={classes.delete}
          aria-describedby={`${id}_title`}
          variant={image ? 'solid' : 'ghost'}
          data-color-scheme={image ? 'dark' : undefined}
        >
          <FormattedMessage id='card.delete' defaultMessage='Remove this' />
        </IconButton>
      )}
    </Comp>
  );
};

interface CardTitleProps {
  children: React.ReactNode;
  image?: React.ReactNode;
  afterContent?: React.ReactNode;
}

export const CardTitle: React.FC<
  CardTitleProps & React.ComponentPropsWithRef<'div'>
> = ({ children, image, afterContent, className, ...props }) => {
  const { id } = use(CardContext);

  return (
    <div {...props} className={classNames(className, classes.title)}>
      {image && <span className={classes.titleImage}>{image}</span>}

      <span id={`${id}_title`}>{children}</span>

      {afterContent && (
        // eslint-disable-next-line no-restricted-syntax -- Allow &bull;
        <span>
          &nbsp;&bull;&nbsp;
          {afterContent}
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
