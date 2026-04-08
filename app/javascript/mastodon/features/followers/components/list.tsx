import { useMemo } from 'react';
import type { FC, ReactNode } from 'react';

import { AccountListItem } from '@/mastodon/components/account_list_item';
import { Column } from '@/mastodon/components/column';
import { ColumnBackButton } from '@/mastodon/components/column_back_button';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import ScrollableList from '@/mastodon/components/scrollable_list';
import BundleColumnError from '@/mastodon/features/ui/components/bundle_column_error';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useAccountVisibility } from '@/mastodon/hooks/useAccountVisibility';
import { useLayout } from '@/mastodon/hooks/useLayout';

import { RemoteHint } from './remote';

export interface AccountList {
  hasMore: boolean;
  isLoading: boolean;
  items: string[];
}

interface AccountListProps {
  accountId?: string | null;
  append?: ReactNode;
  emptyMessage: ReactNode;
  header?: ReactNode;
  footer?: ReactNode;
  list?: AccountList | null;
  loadMore: () => void;
  prependAccountId?: string | null;
  scrollKey: string;
}

export const AccountList: FC<AccountListProps> = ({
  accountId,
  append,
  emptyMessage,
  header,
  footer,
  list,
  loadMore,
  prependAccountId,
  scrollKey,
}) => {
  const account = useAccount(accountId);

  const { blockedBy, hidden, suspended } = useAccountVisibility(accountId);
  const forceEmptyState = blockedBy || hidden || suspended;

  const children = useMemo(() => {
    if (forceEmptyState) {
      return [];
    }
    const children =
      list?.items.map((followerId) => (
        <AccountListItem key={followerId} accountId={followerId} />
      )) ?? [];

    if (prependAccountId) {
      children.unshift(
        <AccountListItem key={prependAccountId} accountId={prependAccountId} />,
      );
    }
    return children;
  }, [prependAccountId, list, forceEmptyState]);

  const { multiColumn } = useLayout();

  // Null means accountId does not exist (e.g. invalid acct). Undefined means loading.
  if (accountId === null) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  if (!accountId || !account) {
    return (
      <Column bindToDocument={!multiColumn}>
        <LoadingIndicator />
      </Column>
    );
  }

  const domain = account.acct.split('@')[1];

  return (
    <Column>
      <ColumnBackButton />

      <ScrollableList
        scrollKey={scrollKey}
        hasMore={!forceEmptyState && list?.hasMore}
        isLoading={list?.isLoading ?? true}
        onLoadMore={loadMore}
        prepend={header}
        alwaysPrepend
        append={append ?? <RemoteHint domain={domain} url={account.url} />}
        emptyMessage={emptyMessage}
        bindToDocument={!multiColumn}
        footer={footer}
      >
        {children}
      </ScrollableList>
    </Column>
  );
};
