import { ColumnBackButton } from 'mastodon/components/column_back_button';
import { useAccountId } from 'mastodon/hooks/useAccountId';
import { useAccountVisibility } from 'mastodon/hooks/useAccountVisibility';

import { AccountHeader } from '../account_timeline/components/account_header';
import Column from '../ui/components/column';

import { EmptyMessage } from './components/empty_message';

const AccountFeatured = () => {
  const accountId = useAccountId();

  const { suspended, blockedBy, hidden } = useAccountVisibility(accountId);
  const forceEmptyState = suspended || blockedBy || hidden;

  return (
    <Column>
      <ColumnBackButton />

      <div className='scrollable scrollable--flex'>
        {accountId && (
          <AccountHeader accountId={accountId} hideTabs={forceEmptyState} />
        )}
        <EmptyMessage
          blockedBy={blockedBy}
          hidden={hidden}
          suspended={suspended}
          accountId={accountId}
        />
      </div>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default AccountFeatured;
