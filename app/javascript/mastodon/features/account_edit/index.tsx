import type { FC } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import { Link } from 'react-router-dom';

import { Column } from '@/mastodon/components/column';
import { ColumnHeader } from '@/mastodon/components/column_header';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import BundleColumnError from '@/mastodon/features/ui/components/bundle_column_error';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';

import classes from './styles.module.scss';

export const AccountEdit: FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const accountId = useCurrentAccountId();
  const account = useAccount(accountId);
  const intl = useIntl();

  if (!accountId) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  if (!account) {
    return (
      <Column bindToDocument={!multiColumn} className={classes.column}>
        <LoadingIndicator />
      </Column>
    );
  }

  return (
    <Column bindToDocument={!multiColumn} className={classes.column}>
      <ColumnHeader
        title={intl.formatMessage({
          id: 'account_edit.column_title',
          defaultMessage: 'Edit Profile',
        })}
        className={classes.header}
        showBackButton
        extraButton={
          <Link to={`/@${account.acct}`} className='button'>
            <FormattedMessage
              id='account_edit.column_button'
              defaultMessage='Done'
            />
          </Link>
        }
      />
    </Column>
  );
};
