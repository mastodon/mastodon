import { forwardRef } from 'react';
import type { ComponentPropsWithoutRef, Key } from 'react';

import classNames from 'classnames';

import type { OmitUnion } from '@/mastodon/utils/types';

import { MiniCard } from '.';
import type { MiniCardProps } from '.';
import classes from './styles.module.css';

interface MiniCardListProps {
  cards?: (MiniCardProps & {
    key?: Key;
  })[];
}

export const MiniCardList = forwardRef<
  HTMLDListElement,
  OmitUnion<ComponentPropsWithoutRef<'dl'>, MiniCardListProps>
>(({ cards = [], className, children }, ref) => {
  if (!cards.length) {
    return null;
  }

  return (
    <dl className={classNames(classes.list, className)} ref={ref}>
      {cards.map((card, index) => (
        <MiniCard key={card.key ?? index} {...card} />
      ))}
      {children}
    </dl>
  );
});
MiniCardList.displayName = 'MiniCardList';
