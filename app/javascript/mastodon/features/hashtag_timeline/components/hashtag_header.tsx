import { useMemo } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { useHashtag } from '@/mastodon/hooks/useHashtag';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import { Button } from 'mastodon/components/button';
import { Dropdown } from 'mastodon/components/dropdown_menu';
import { ShortNumber } from 'mastodon/components/short_number';
import { useIdentity } from 'mastodon/identity_context';
import { PERMISSION_MANAGE_TAXONOMIES } from 'mastodon/permissions';

export const messages = defineMessages({
  followHashtag: { id: 'hashtag.follow', defaultMessage: 'Follow hashtag' },
  unfollowHashtag: {
    id: 'hashtag.unfollow',
    defaultMessage: 'Unfollow hashtag',
  },
  adminModeration: {
    id: 'hashtag.admin_moderation',
    defaultMessage: 'Open moderation interface for #{name}',
  },
  feature: { id: 'hashtag.feature', defaultMessage: 'Feature on profile' },
  unfeature: {
    id: 'hashtag.unfeature',
    defaultMessage: "Don't feature on profile",
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
  const { tag, toggleFeature, toggleFollow } = useHashtag(tagId);

  const menu = useMemo(() => {
    const arr = [];

    if (tag && signedIn) {
      arr.push({
        text: intl.formatMessage(
          tag.featuring ? messages.unfeature : messages.feature,
        ),
        action: toggleFeature,
      });

      arr.push(null);

      if (
        (permissions & PERMISSION_MANAGE_TAXONOMIES) ===
        PERMISSION_MANAGE_TAXONOMIES
      ) {
        arr.push({
          text: intl.formatMessage(messages.adminModeration, { name: tagId }),
          href: `/admin/tags/${tag.id}`,
        });
      }
    }

    return arr;
  }, [tag, signedIn, intl, toggleFeature, permissions, tagId]);

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
            <Dropdown
              disabled={menu.length === 0}
              items={menu}
              icon='ellipsis-v'
              iconComponent={MoreHorizIcon}
            />
          )}

          {signedIn && (
            <Button
              onClick={toggleFollow}
              text={intl.formatMessage(
                tag.following
                  ? messages.unfollowHashtag
                  : messages.followHashtag,
              )}
            />
          )}
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
