import type { FC, MouseEventHandler } from 'react';

import type { MessageDescriptor } from 'react-intl';
import { defineMessages, useIntl } from 'react-intl';

import ChevronLeftIcon from '@/material-icons/400-24px/chevron_left.svg?react';
import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';

import { IconButton } from '../icon_button';

export interface CarouselPaginationProps {
  onNext: MouseEventHandler;
  onPrev: MouseEventHandler;
  current: number;
  max: number;
  className?: string;
  messages?: Record<MessageKeys, MessageDescriptor>;
}

export const defaultMessages = defineMessages({
  previous: { id: 'carousel.previous', defaultMessage: 'Previous' },
  next: { id: 'carousel.next', defaultMessage: 'Next' },
  slide: {
    id: 'carousel.slide',
    defaultMessage: '{index} of {total}',
  },
  current: {
    id: 'carousel.current',
    defaultMessage: '<sr>Slide</sr> {current, number} / {max, number}',
  },
});

type MessageKeys = keyof typeof defaultMessages;

export const CarouselPagination: FC<CarouselPaginationProps> = ({
  onNext,
  onPrev,
  current,
  max,
  className = '',
  messages = defaultMessages,
}) => {
  const intl = useIntl();
  return (
    <div className={className}>
      <IconButton
        title={intl.formatMessage(messages.previous)}
        icon='chevron-left'
        iconComponent={ChevronLeftIcon}
        onClick={onPrev}
      />
      <span aria-live='polite'>
        {intl.formatMessage(messages.current, {
          current: current + 1,
          max,
          sr: (chunk) => <span className='sr-only'>{chunk}</span>,
        })}
      </span>
      <IconButton
        title={intl.formatMessage(messages.next)}
        icon='chevron-right'
        iconComponent={ChevronRightIcon}
        onClick={onNext}
      />
    </div>
  );
};
