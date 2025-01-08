import { useCallback, useMemo, useState, useEffect } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { isFulfilled } from '@reduxjs/toolkit';

import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import {
  fetchHashtag,
  followHashtag,
  unfollowHashtag,
} from 'mastodon/actions/tags_typed';
import type { ApiHashtagJSON } from 'mastodon/api_types/tags';
import { Button } from 'mastodon/components/button';
import { ShortNumber } from 'mastodon/components/short_number';
import DropdownMenu from 'mastodon/containers/dropdown_menu_container';
import { useIdentity } from 'mastodon/identity_context';
import { PERMISSION_MANAGE_TAXONOMIES } from 'mastodon/permissions';
import { useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  followHashtag: { id: 'hashtag.follow', defaultMessage: 'Follow hashtag' },
  unfollowHashtag: {
    id: 'hashtag.unfollow',
    defaultMessage: 'Unfollow hashtag',
  },
  adminModeration: {
    id: 'hashtag.admin_moderation',
    defaultMessage: 'Open moderation interface for #{name}',
  },
});

const usesRenderer = (displayNumber: React.ReactNode, pluralReady: number) => (
  <FormattedMessage
    id='hashtag.counter_by_uses'
    defaultMessage='{count, plural, one {{counter} post} other {{counter} posts}}'
    values={{
      count: pluralReady,
      counter: <strong>{displayNumber}</strong>,
    }}
  />
);

const peopleRenderer = (
  displayNumber: React.ReactNode,
  pluralReady: number,
) => (
  <FormattedMessage
    id='hashtag.counter_by_accounts'
    defaultMessage='{count, plural, one {{counter} participant} other {{counter} participants}}'
    values={{
      count: pluralReady,
      counter: <strong>{displayNumber}</strong>,
    }}
  />
);

const usesTodayRenderer = (
  displayNumber: React.ReactNode,
  pluralReady: number,
) => (
  <FormattedMessage
    id='hashtag.counter_by_uses_today'
    defaultMessage='{count, plural, one {{counter} post} other {{counter} posts}} today'
    values={{
      count: pluralReady,
      counter: <strong>{displayNumber}</strong>,
    }}
  />
);

export const HashtagHeader: React.FC<{
  tagId: string;
}> = ({ tagId }) => {
  const intl = useIntl();
  const { signedIn, permissions } = useIdentity();
  const dispatch = useAppDispatch();
  const [tag, setTag] = useState<ApiHashtagJSON>();

  useEffect(() => {
    void dispatch(fetchHashtag({ tagId })).then((result) => {
      if (isFulfilled(result)) {
        setTag(result.payload);
      }

      return '';
    });
  }, [dispatch, tagId, setTag]);

  const menu = useMemo(() => {
    const tmp = [];

    if (
      tag &&
      signedIn &&
      (permissions & PERMISSION_MANAGE_TAXONOMIES) ===
        PERMISSION_MANAGE_TAXONOMIES
    ) {
      tmp.push({
        text: intl.formatMessage(messages.adminModeration, { name: tag.id }),
        href: `/admin/tags/${tag.id}`,
      });
    }

    return tmp;
  }, [signedIn, permissions, intl, tag]);

  const handleFollow = useCallback(() => {
    if (!signedIn || !tag) {
      return;
    }

    if (tag.following) {
      setTag((hashtag) => hashtag && { ...hashtag, following: false });

      void dispatch(unfollowHashtag({ tagId })).then((result) => {
        if (isFulfilled(result)) {
          setTag(result.payload);
        }

        return '';
      });
    } else {
      setTag((hashtag) => hashtag && { ...hashtag, following: true });

      void dispatch(followHashtag({ tagId })).then((result) => {
        if (isFulfilled(result)) {
          setTag(result.payload);
        }

        return '';
      });
    }
  }, [dispatch, setTag, signedIn, tag, tagId]);

  if (!tag) {
    return null;
  }

  const [uses, people] = tag.history.reduce(
    (arr, day) => [
      arr[0] + parseInt(day.uses),
      arr[1] + parseInt(day.accounts),
    ],
    [0, 0],
  );
  const dividingCircle = <span aria-hidden>{' · '}</span>;

  return (
    <div className='hashtag-header'>
      <div className='hashtag-header__header'>
        <h1>#{tag.name}</h1>

        <div className='hashtag-header__header__buttons'>
          {menu.length > 0 && (
            <DropdownMenu
              disabled={menu.length === 0}
              items={menu}
              icon='ellipsis-v'
              iconComponent={MoreHorizIcon}
              size={24}
              direction='right'
            />
          )}

          <Button
            onClick={handleFollow}
            text={intl.formatMessage(
              tag.following ? messages.unfollowHashtag : messages.followHashtag,
            )}
            disabled={!signedIn}
          />
        </div>
      </div>

      <div>
        <ShortNumber value={uses} renderer={usesRenderer} />
        {dividingCircle}
        <ShortNumber value={people} renderer={peopleRenderer} />
        {dividingCircle}
        <ShortNumber
          value={parseInt(tag.history[0].uses)}
          renderer={usesTodayRenderer}
        />
      </div>
    </div>
  );
};
