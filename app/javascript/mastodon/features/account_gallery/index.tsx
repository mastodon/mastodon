import { useEffect, useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { List as ImmutableList, isList } from 'immutable';

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
import {
  useAppSelector,
  useAppDispatch,
  createAppSelector,
} from 'mastodon/store';

import { MediaItem } from './components/media_item';

const emptyList = ImmutableList<MediaAttachment>();

const selectGalleryTimeline = createAppSelector(
  [
    (_state, accountId?: string | null) => accountId,
    (state) => state.timelines,
    (state) => state.accounts,
    (state) => state.statuses,
  ],
  (accountId, timelines, accounts, statuses) => {
    let items = emptyList;
    if (!accountId) {
      return {
        items,
        hasMore: false,
        isLoading: false,
        withReplies: false,
      };
    }
    const account = accounts.get(accountId);
    if (!account) {
      return {
        items,
        hasMore: false,
        isLoading: false,
        withReplies: false,
      };
    }

    const { show_media, show_media_replies } = account;
    // If the account disabled showing media, don't display anything.
    if (!show_media) {
      return {
        items,
        hasMore: false,
        isLoading: false,
        withReplies: false,
      };
    }

    const withReplies = show_media_replies;
    const timeline = timelines.get(
      `account:${accountId}:media${withReplies ? ':with_replies' : ''}`,
    );
    const statusIds = timeline?.get('items');

    if (isList(statusIds)) {
      for (const statusId of statusIds) {
        const status = statuses.get(statusId);
        items = items.concat(
          (
            status?.get('media_attachments') as ImmutableList<MediaAttachment>
          ).map((media) => media.set('status', status)),
        );
      }
    }

    return {
      items,
      hasMore: !!timeline?.get('hasMore'),
      isLoading: timeline?.get('isLoading') ? true : false,
      withReplies,
    };
  },
);

export const AccountGallery: React.FC<{
  multiColumn: boolean;
}> = ({ multiColumn }) => {
  const dispatch = useAppDispatch();
  const accountId = useAccountId();
  const {
    isLoading,
    items: attachments,
    hasMore,
    withReplies,
  } = useAppSelector((state) => selectGalleryTimeline(state, accountId));

  const { suspended, blockedBy, hidden } = useAccountVisibility(accountId);

  const maxId = attachments.last()?.getIn(['status', 'id']) as
    | string
    | undefined;

  useEffect(() => {
    if (accountId) {
      void dispatch(expandAccountMediaTimeline(accountId, { withReplies }));
    }
  }, [dispatch, accountId, withReplies]);

  const handleLoadMore = useCallback(() => {
    if (maxId) {
      void dispatch(
        expandAccountMediaTimeline(accountId, { maxId, withReplies }),
      );
    }
  }, [maxId, dispatch, accountId, withReplies]);

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
