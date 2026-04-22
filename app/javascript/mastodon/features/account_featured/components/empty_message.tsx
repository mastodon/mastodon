import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { useParams } from 'react-router';
import { Link } from 'react-router-dom';

import { openModal } from '@/mastodon/actions/modal';
import { Button } from '@/mastodon/components/button';
import { EmptyState } from '@/mastodon/components/empty_state';
import { LimitedAccountHint } from '@/mastodon/features/account_timeline/components/limited_account_hint';
import { areCollectionsEnabled } from '@/mastodon/features/collections/utils';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { useAppDispatch } from '@/mastodon/store';

interface EmptyMessageProps {
  suspended: boolean;
  hidden: boolean;
  blockedBy: boolean;
  accountId?: string;
  withoutAddCollectionButton?: boolean;
}

export const EmptyMessage: React.FC<EmptyMessageProps> = ({
  accountId,
  suspended,
  hidden,
  blockedBy,
  withoutAddCollectionButton,
}) => {
  const { acct } = useParams<{ acct?: string }>();
  const me = useCurrentAccountId();

  const dispatch = useAppDispatch();

  const confirmHideFeaturedTab = useCallback(() => {
    void dispatch(
      openModal({
        modalType: 'ACCOUNT_HIDE_FEATURED_TAB',
        modalProps: {},
      }),
    );
  }, [dispatch]);

  if (!accountId) {
    return null;
  }

  let title: React.ReactNode = null;
  let message: React.ReactNode = null;

  const hasCollections = areCollectionsEnabled();

  if (me === accountId) {
    if (hasCollections) {
      // Return only here to insert the "Create a collection" button as the action for the empty state.
      return (
        <EmptyState
          title={
            <FormattedMessage
              id='empty_column.account_featured_self.showcase_accounts'
              defaultMessage='Showcase your favorite accounts'
            />
          }
          message={
            <FormattedMessage
              id='empty_column.account_featured_self.showcase_accounts_desc'
              defaultMessage='Collections are curated lists of accounts to help others discover more of the Fediverse.'
            />
          }
        >
          {!withoutAddCollectionButton && (
            <Link to='/collections/new' className='button'>
              <FormattedMessage
                id='empty_column.account_featured_self.no_collections_button'
                defaultMessage='Create a collection'
              />
            </Link>
          )}
          <Button secondary onClick={confirmHideFeaturedTab}>
            <FormattedMessage
              id='empty_column.account_featured_self.no_collections_hide_tab'
              defaultMessage='Hide this tab instead'
            />
          </Button>
        </EmptyState>
      );
    } else {
      title = (
        <FormattedMessage
          id='empty_column.account_featured_self.pre_collections'
          defaultMessage='Stay tuned for Collections'
        />
      );
      message = (
        <FormattedMessage
          id='empty_column.account_featured_self.pre_collections_desc'
          defaultMessage='Collections (coming in Mastodon 4.6) allow you to create your own curated lists of accounts to recommend to others.'
        />
      );
    }
  } else if (suspended) {
    title = (
      <FormattedMessage
        id='empty_column.account_suspended'
        defaultMessage='Account suspended'
      />
    );
  } else if (hidden) {
    message = <LimitedAccountHint accountId={accountId} />;
  } else if (blockedBy) {
    title = (
      <FormattedMessage
        id='empty_column.account_unavailable'
        defaultMessage='Profile unavailable'
      />
    );
  } else {
    if (acct) {
      title = (
        <FormattedMessage
          id='empty_column.account_featured.other'
          defaultMessage='{acct} has not featured anything yet.'
          values={{ acct }}
        />
      );
    } else {
      title = (
        <FormattedMessage
          id='empty_column.account_featured_unknown.other'
          defaultMessage='This account has not featured anything yet.'
        />
      );
    }
  }

  return <EmptyState title={title} message={message} />;
};
