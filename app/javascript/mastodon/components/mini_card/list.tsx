import { forwardRef } from 'react';
import type { ComponentPropsWithoutRef, Key } from 'react';

import classNames from 'classnames';

import type { Merge } from 'type-fest';

import { MiniCard } from '.';
import type { MiniCardProps as BaseCardProps } from '.';
import classes from './styles.module.css';

export type MiniCardProps = BaseCardProps & {
  key?: Key;
};

interface MiniCardListProps {
  cards?: MiniCardProps[];
}

export const MiniCardList = forwardRef<
  HTMLDListElement,
  Merge<ComponentPropsWithoutRef<'dl'>, MiniCardListProps>
>(({ cards = [], className, children, ...props }, ref) => {
  if (!cards.length) {
    return null;
  }

  return (
    <dl {...props} className={classNames(classes.list, className)} ref={ref}>
      {cards.map((card, index) => (
        <MiniCard key={card.key ?? index} {...card} />
      ))}
      {children}
    </dl>
  );
});
MiniCardList.displayName = 'MiniCardList';
