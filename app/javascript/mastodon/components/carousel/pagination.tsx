import type { FC, MouseEventHandler } from 'react';

import type { MessageDescriptor } from 'react-intl';
import { useIntl } from 'react-intl';

import ChevronLeftIcon from '@/material-icons/400-24px/chevron_left.svg?react';
import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';

import { IconButton } from '../icon_button';

import type { MessageKeys } from './index';

export interface CarouselPaginationProps {
  onNext: MouseEventHandler;
  onPrev: MouseEventHandler;
  current: number;
  max: number;
  className?: string;
  messages: Record<MessageKeys, MessageDescriptor>;
}

export const CarouselPagination: FC<CarouselPaginationProps> = ({
  onNext,
  onPrev,
  current,
  max,
  className = '',
  messages,
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
