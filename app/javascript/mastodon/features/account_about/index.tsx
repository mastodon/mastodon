import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { useParams } from 'react-router';

import { AccountBio } from '@/mastodon/components/account_bio';
import { Column } from '@/mastodon/components/column';
import { ColumnBackButton } from '@/mastodon/components/column_back_button';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import BundleColumnError from '@/mastodon/features/ui/components/bundle_column_error';
import type { AccountId } from '@/mastodon/hooks/useAccountId';
import { useAccountId } from '@/mastodon/hooks/useAccountId';
import { useAccountVisibility } from '@/mastodon/hooks/useAccountVisibility';
import { createAppSelector, useAppSelector } from '@/mastodon/store';

import { AccountHeader } from '../account_timeline/components/account_header';
import { AccountHeaderFields } from '../account_timeline/components/fields';
import { LimitedAccountHint } from '../account_timeline/components/limited_account_hint';

import classes from './styles.module.css';

const selectIsProfileEmpty = createAppSelector(
  [(state) => state.accounts, (_, accountId: AccountId) => accountId],
  (accounts, accountId) => {
    // Null means still loading, otherwise it's a boolean.
    if (!accountId) {
      return null;
    }
    const account = accounts.get(accountId);
    if (!account) {
      return null;
    }
    return !account.note && !account.fields.size;
  },
);

export const AccountAbout: FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const accountId = useAccountId();
  const { blockedBy, hidden, suspended } = useAccountVisibility(accountId);
  const forceEmptyState = blockedBy || hidden || suspended;

  const isProfileEmpty = useAppSelector((state) =>
    selectIsProfileEmpty(state, accountId),
  );

  if (accountId === null) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  if (!accountId || isProfileEmpty === null) {
    return (
      <Column bindToDocument={!multiColumn}>
        <LoadingIndicator />
      </Column>
    );
  }

  const showEmptyMessage = forceEmptyState || isProfileEmpty;

  return (
    <Column bindToDocument={!multiColumn}>
      <ColumnBackButton />
      <div className='scrollable scrollable--flex'>
        <AccountHeader accountId={accountId} hideTabs={forceEmptyState} />
        <div className={classes.wrapper}>
          {!showEmptyMessage ? (
            <>
              <AccountBio
                accountId={accountId}
                className={`${classes.bio} account__header__content`}
              />
              <AccountHeaderFields accountId={accountId} />
            </>
          ) : (
            <div className='empty-column-indicator'>
              <EmptyMessage accountId={accountId} />
            </div>
          )}
        </div>
      </div>
    </Column>
  );
};

const EmptyMessage: FC<{ accountId: string }> = ({ accountId }) => {
  const { blockedBy, hidden, suspended } = useAccountVisibility(accountId);
  const currentUserId = useAppSelector(
    (state) => state.meta.get('me') as string | null,
  );
  const { acct } = useParams<{ acct?: string }>();

  if (suspended) {
    return (
      <FormattedMessage
        id='empty_column.account_suspended'
        defaultMessage='Account suspended'
      />
    );
  } else if (hidden) {
    return <LimitedAccountHint accountId={accountId} />;
  } else if (blockedBy) {
    return (
      <FormattedMessage
        id='empty_column.account_unavailable'
        defaultMessage='Profile unavailable'
      />
    );
  } else if (accountId === currentUserId) {
    return (
      <FormattedMessage
        id='empty_column.account_about.me'
        defaultMessage='You have not added any information about yourself yet.'
      />
    );
  }

  return (
    <FormattedMessage
      id='empty_column.account_about.other'
      defaultMessage='{acct} has not added any information about themselves yet.'
      values={{ acct }}
    />
  );
};
