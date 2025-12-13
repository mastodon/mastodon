import { useEffect, useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { createSelector } from '@reduxjs/toolkit';
import type { Map as ImmutableMap } from 'immutable';
import { List as ImmutableList } from 'immutable';

import { openModal } from 'mastodon/actions/modal';
import { expandAccountMediaTimeline } from 'mastodon/actions/timelines';
import { ColumnBackButton } from 'mastodon/components/column_back_button';
import { RemoteHint } from 'mastodon/components/remote_hint';
import ScrollableList from 'mastodon/components/scrollable_list';
import { AccountHeader } from 'mastodon/features/account_timeline/components/account_header';
import { LimitedAccountHint } from 'mastodon/features/account_timeline/components/limited_account_hint';
import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';
import Column from 'mastodon/features/ui/components/column';
import { useAccountId } from 'mastodon/hooks/useAccountId';
import { useAccountVisibility } from 'mastodon/hooks/useAccountVisibility';
import type { MediaAttachment } from 'mastodon/models/media_attachment';
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

export const AccountGallery: React.FC<{
  multiColumn: boolean;
}> = ({ multiColumn }) => {
  const dispatch = useAppDispatch();
  const accountId = useAccountId();
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
  const isAccount = !!account;

  const { suspended, blockedBy, hidden } = useAccountVisibility(accountId);

  const maxId = attachments.last()?.getIn(['status', 'id']) as
    | string
    | undefined;

  useEffect(() => {
    if (accountId && isAccount) {
      void dispatch(expandAccountMediaTimeline(accountId));
    }
  }, [dispatch, accountId, isAccount]);

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

  if (accountId === null) {
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
    } else if (attachments.isEmpty()) {
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
            <AccountHeader accountId={accountId} hideTabs={forceEmptyState} />
          )
        }
        alwaysPrepend
        append={accountId && <RemoteHint accountId={accountId} />}
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
