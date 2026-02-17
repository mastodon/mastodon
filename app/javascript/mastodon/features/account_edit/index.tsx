import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { Column } from '@/mastodon/components/column';
import { ColumnHeader } from '@/mastodon/components/column_header';
import BundleColumnError from '@/mastodon/features/ui/components/bundle_column_error';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import AccountCircleIcon from '@/material-icons/400-24px/account_circle.svg?react';

const messages = defineMessages({
  title: { id: 'account_edit.column_title', defaultMessage: 'Edit Profile' },
  doneButton: { id: 'account_edit.done_button', defaultMessage: 'Done' },
});

export const AccountEdit: FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const accountId = useCurrentAccountId();
  const intl = useIntl();

  if (!accountId) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  return (
    <Column label='Edit Profile' bindToDocument={!multiColumn}>
      <ColumnHeader
        multiColumn={multiColumn}
        title={intl.formatMessage(messages.title)}
        icon='account-circle'
        iconComponent={AccountCircleIcon}
        extraButton={
          <button
            aria-label={intl.formatMessage(messages.doneButton)}
            title={intl.formatMessage(messages.doneButton)}
            className='column-header__button'
            type='button'
          >
            {intl.formatMessage(messages.doneButton)}
          </button>
        }
      />
    </Column>
  );
};
