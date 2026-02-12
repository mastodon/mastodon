import type { FC } from 'react';

import { AccountBio } from '@/mastodon/components/account_bio';
import { Column } from '@/mastodon/components/column';
import { ColumnBackButton } from '@/mastodon/components/column_back_button';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import BundleColumnError from '@/mastodon/features/ui/components/bundle_column_error';
import { useAccountId } from '@/mastodon/hooks/useAccountId';
import { useAccountVisibility } from '@/mastodon/hooks/useAccountVisibility';

import { AccountHeader } from '../account_timeline/components/account_header';
import { AccountHeaderFields } from '../account_timeline/components/fields';

import classes from './styles.module.css';

export const AccountAbout: FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const accountId = useAccountId();
  const { blockedBy, hidden, suspended } = useAccountVisibility(accountId);
  const forceEmptyState = blockedBy || hidden || suspended;

  if (accountId === null) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  if (!accountId) {
    return (
      <Column bindToDocument={!multiColumn}>
        <LoadingIndicator />
      </Column>
    );
  }

  return (
    <Column bindToDocument={!multiColumn}>
      <ColumnBackButton />
      <div className='scrollable scrollable--flex'>
        <AccountHeader accountId={accountId} hideTabs={forceEmptyState} />
        <div className={classes.wrapper}>
          <AccountBio
            accountId={accountId}
            className={`${classes.bio} account__header__content`}
          />
          <AccountHeaderFields accountId={accountId} />
        </div>
      </div>
    </Column>
  );
};
