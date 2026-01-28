import type { FC, Key, MouseEventHandler } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { useOverflow } from '@/mastodon/hooks/useOverflow';

import { MiniCard } from '.';
import type { MiniCardProps } from '.';
import classes from './styles.module.css';

interface MiniCardListProps {
  cards?: (Pick<MiniCardProps, 'label' | 'value' | 'className'> & {
    key?: Key;
  })[];
  className?: string;
  onOverflowClick?: MouseEventHandler;
}

export const MiniCardList: FC<MiniCardListProps> = ({
  cards = [],
  className,
  onOverflowClick,
}) => {
  const {
    wrapperRef,
    listRef,
    hiddenCount,
    hasOverflow,
    hiddenIndex,
    maxWidth,
  } = useOverflow();

  if (!cards.length) {
    return null;
  }

  return (
    <div className={classNames(classes.wrapper, className)} ref={wrapperRef}>
      <dl className={classes.list} ref={listRef} style={{ maxWidth }}>
        {cards.map((card, index) => (
          <MiniCard
            key={card.key ?? index}
            label={card.label}
            value={card.value}
            hidden={hasOverflow && index >= hiddenIndex}
            className={card.className}
          />
        ))}
      </dl>
      {cards.length > 1 && (
        <div>
          <button
            type='button'
            className={classNames(classes.more, !hasOverflow && classes.hidden)}
            onClick={onOverflowClick}
          >
            <FormattedMessage
              id='minicard.more_items'
              defaultMessage='+{count}'
              values={{ count: hiddenCount }}
            />
          </button>
        </div>
      )}
    </div>
  );
};
