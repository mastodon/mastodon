import type { FC, ReactNode } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import { useDismissible } from '../hooks/useDismissible';

import { IconButton } from './icon_button';

const messages = defineMessages({
  dismiss: { id: 'dismissable_banner.dismiss', defaultMessage: 'Dismiss' },
});

interface Props {
  id: string;
  children: ReactNode;
}

export const DismissableBanner: FC<Props> = ({ id, children }) => {
  const intl = useIntl();
  const { wasDismissed, dismiss } = useDismissible(id);

  if (wasDismissed) {
    return null;
  }

  return (
    <div className='dismissable-banner'>
      <div className='dismissable-banner__action'>
        <IconButton
          icon='times'
          iconComponent={CloseIcon}
          title={intl.formatMessage(messages.dismiss)}
          onClick={dismiss}
        />
      </div>

      <div className='dismissable-banner__message'>{children}</div>
    </div>
  );
};
