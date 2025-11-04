import { useCallback } from 'react';
import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { cancelPasteLinkCompose } from '@/mastodon/actions/compose_typed';
import { useAppDispatch } from '@/mastodon/store';
import CancelFillIcon from '@/material-icons/400-24px/cancel-fill.svg?react';
import { DisplayName } from 'mastodon/components/display_name';
import { IconButton } from 'mastodon/components/icon_button';
import { Skeleton } from 'mastodon/components/skeleton';

const messages = defineMessages({
  quote_cancel: { id: 'status.quote.cancel', defaultMessage: 'Cancel quote' },
});

export const QuotePlaceholder: FC = () => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const handleQuoteCancel = useCallback(() => {
    dispatch(cancelPasteLinkCompose());
  }, [dispatch]);

  return (
    <div className='status__quote'>
      <div className='status'>
        <div className='status__info'>
          <div className='status__avatar'>
            <Skeleton width='32px' height='32px' />
          </div>
          <div className='status__display-name'>
            <DisplayName />
          </div>
          <IconButton
            onClick={handleQuoteCancel}
            className='status__quote-cancel'
            title={intl.formatMessage(messages.quote_cancel)}
            icon='cancel-fill'
            iconComponent={CancelFillIcon}
          />
        </div>
        <div className='status__content'>
          <Skeleton />
        </div>
      </div>
    </div>
  );
};
