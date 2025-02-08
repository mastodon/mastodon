import { useEffect, useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { useParams } from 'react-router-dom';

import { createSelector } from '@reduxjs/toolkit';
import type { Map as ImmutableMap } from 'immutable';
import { List as ImmutableList } from 'immutable';

import { lookupAccount, fetchAccount } from 'mastodon/actions/accounts';
import { openModal } from 'mastodon/actions/modal';
import { connectProfileStream } from 'mastodon/actions/streaming';
import { expandAccountMediaTimeline } from 'mastodon/actions/timelines';
import { ColumnBackButton } from 'mastodon/components/column_back_button';
import ScrollableList from 'mastodon/components/scrollable_list';
import { TimelineHint } from 'mastodon/components/timeline_hint';
import { Header } from 'mastodon/features/account_timeline/components/header';
import { LimitedAccountHint } from 'mastodon/features/account_timeline/components/limited_account_hint';
import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';
import Column from 'mastodon/features/ui/components/column';
import type { MediaAttachment } from 'mastodon/models/media_attachment';
import { normalizeForLookup } from 'mastodon/reducers/accounts_map';
import { getAccountHidden } from 'mastodon/selectors/accounts';
import type { RootState } from 'mastodon/store';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { MediaItem } from './components/media_item';

const getAccountGallery = createSelector(
  [
    (state: RootState, accountId: string) =>
      (state.timelines as ImmutableMap<string, unknown>).getIn(
        [`account:${accountId}:media`, 'items'],
        ImmutableList(),
      ) as ImmutableList<string>,
    (state: RootState) => state.statuses,
  ],
  (statusIds, statuses) => {
    let items = ImmutableList<MediaAttachment>();

    statusIds.forEach((statusId) => {
      const status = statuses.get(statusId) as
        | ImmutableMap<string, unknown>
        | undefined;

      if (status) {
        items = items.concat(
          (
            status.get('media_attachments') as ImmutableList<MediaAttachment>
          ).map((media) => media.set('status', status)),
        );
      }
    });

    return items;
  },
);

interface Params {
  acct?: string;
  id?: string;
}

const RemoteHint: React.FC<{
  accountId: string;
}> = ({ accountId }) => {
  const account = useAppSelector((state) => state.accounts.get(accountId));
  const acct = account?.acct;
  const url = account?.url;
  const domain = acct ? acct.split('@')[1] : undefined;

  if (!url) {
    return null;
  }

  return (
    <TimelineHint
      url={url}
      message={
        <FormattedMessage
          id='hints.profiles.posts_may_be_missing'
          defaultMessage='Some posts from this profile may be missing.'
        />
      }
      label={
        <FormattedMessage
          id='hints.profiles.see_more_posts'
          defaultMessage='See more posts on {domain}'
          values={{ domain: <strong>{domain}</strong> }}
        />
      }
    />
  );
};

export const AccountGallery: React.FC<{
  multiColumn: boolean;
}> = ({ multiColumn }) => {
  const { acct, id } = useParams<Params>();
  const dispatch = useAppDispatch();
  const accountId = useAppSelector(
    (state) =>
      id ??
      (state.accounts_map.get(normalizeForLookup(acct)) as string | undefined),
  );
  const attachments = useAppSelector((state) =>
    accountId
      ? getAccountGallery(state, accountId)
      : ImmutableList<MediaAttachment>(),
  );
  const isLoading = useAppSelector((state) =>
    (state.timelines as ImmutableMap<string, unknown>).getIn([
      `account:${accountId}:media`,
      'isLoading',
    ]),
  );
  const hasMore = useAppSelector((state) =>
    (state.timelines as ImmutableMap<string, unknown>).getIn([
      `account:${accountId}:media`,
      'hasMore',
    ]),
  );
  const account = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId) : undefined,
  );
  const blockedBy = useAppSelector(
    (state) =>
      state.relationships.getIn([accountId, 'blocked_by'], false) as boolean,
  );
  const suspended = useAppSelector(
    (state) => state.accounts.getIn([accountId, 'suspended'], false) as boolean,
  );
  const isAccount = !!account;
  const remote = account?.acct !== account?.username;
  const hidden = useAppSelector((state) =>
    accountId ? getAccountHidden(state, accountId) : false,
  );
  const maxId = attachments.last()?.getIn(['status', 'id']) as
    | string
    | undefined;

  useEffect(() => {
    if (!accountId) {
      dispatch(lookupAccount(acct));
    }
  }, [dispatch, accountId, acct]);

  useEffect(() => {
    if (accountId && !isAccount) {
      dispatch(fetchAccount(accountId));
    }

    if (accountId) {
      void dispatch(expandAccountMediaTimeline(accountId));
    }
  }, [dispatch, accountId, isAccount]);

  useEffect(() => {
    if (!accountId) {
      return;
    }

    // eslint-disable-next-line @typescript-eslint/no-confusing-void-expression
    const disconnect = dispatch(
      connectProfileStream(accountId, { onlyMedia: true }),
    ) as unknown as () => void;

    return () => {
      disconnect();
    };
  }, [dispatch, accountId]);

  const handleLoadMore = useCallback(() => {
    if (maxId) {
      void dispatch(expandAccountMediaTimeline(accountId, { maxId }));
    }
  }, [dispatch, accountId, maxId]);

  const handleOpenMedia = useCallback(
    (attachment: MediaAttachment) => {
      const statusId = attachment.getIn(['status', 'id']);
      const lang = attachment.getIn(['status', 'language']);

      if (attachment.get('type') === 'video') {
        dispatch(
          openModal({
            modalType: 'VIDEO',
            modalProps: {
              media: attachment,
              statusId,
              lang,
              options: { autoPlay: true },
            },
          }),
        );
      } else if (attachment.get('type') === 'audio') {
        dispatch(
          openModal({
            modalType: 'AUDIO',
            modalProps: {
              media: attachment,
              statusId,
              lang,
              options: { autoPlay: true },
            },
          }),
        );
      } else {
        const media = attachment.getIn([
          'status',
          'media_attachments',
        ]) as ImmutableList<MediaAttachment>;
        const index = media.findIndex(
          (x) => x.get('id') === attachment.get('id'),
        );

        dispatch(
          openModal({
            modalType: 'MEDIA',
            modalProps: { media, index, statusId, lang },
          }),
        );
      }
    },
    [dispatch],
  );

  if (accountId && !isAccount) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  let emptyMessage;

  if (accountId) {
    if (suspended) {
      emptyMessage = (
        <FormattedMessage
          id='empty_column.account_suspended'
          defaultMessage='Account suspended'
        />
      );
    } else if (hidden) {
      emptyMessage = <LimitedAccountHint accountId={accountId} />;
    } else if (blockedBy) {
      emptyMessage = (
        <FormattedMessage
          id='empty_column.account_unavailable'
          defaultMessage='Profile unavailable'
        />
      );
    } else if (remote && attachments.isEmpty()) {
      emptyMessage = <RemoteHint accountId={accountId} />;
    } else {
      emptyMessage = (
        <FormattedMessage
          id='empty_column.account_timeline'
          defaultMessage='No posts found'
        />
      );
    }
  }

  const forceEmptyState = suspended || blockedBy || hidden;

  return (
    <Column>
      <ColumnBackButton />

      <ScrollableList
        className='account-gallery__container'
        prepend={
          accountId && (
            <Header accountId={accountId} hideTabs={forceEmptyState} />
          )
        }
        alwaysPrepend
        append={remote && accountId && <RemoteHint accountId={accountId} />}
        scrollKey='account_gallery'
        isLoading={isLoading}
        hasMore={!forceEmptyState && hasMore}
        onLoadMore={handleLoadMore}
        emptyMessage={emptyMessage}
        bindToDocument={!multiColumn}
      >
        {attachments.map((attachment) => (
          <MediaItem
            key={attachment.get('id') as string}
            attachment={attachment}
            onOpenMedia={handleOpenMedia}
          />
        ))}
      </ScrollableList>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default AccountGallery;
