import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';

import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import { Button } from 'mastodon/components/button';
import { ShortNumber } from 'mastodon/components/short_number';
import DropdownMenuContainer from 'mastodon/containers/dropdown_menu_container';
import { withIdentity } from 'mastodon/identity_context';
import { PERMISSION_MANAGE_TAXONOMIES } from 'mastodon/permissions';

const messages = defineMessages({
  followHashtag: { id: 'hashtag.follow', defaultMessage: 'Follow hashtag' },
  unfollowHashtag: { id: 'hashtag.unfollow', defaultMessage: 'Unfollow hashtag' },
  adminModeration: { id: 'hashtag.admin_moderation', defaultMessage: 'Open moderation interface for #{name}' },
});

const usesRenderer = (displayNumber, pluralReady) => (
  <FormattedMessage
    id='hashtag.counter_by_uses'
    defaultMessage='{count, plural, one {{counter} post} other {{counter} posts}}'
    values={{
      count: pluralReady,
      counter: <strong>{displayNumber}</strong>,
    }}
  />
);

const peopleRenderer = (displayNumber, pluralReady) => (
  <FormattedMessage
    id='hashtag.counter_by_accounts'
    defaultMessage='{count, plural, one {{counter} participant} other {{counter} participants}}'
    values={{
      count: pluralReady,
      counter: <strong>{displayNumber}</strong>,
    }}
  />
);

const usesTodayRenderer = (displayNumber, pluralReady) => (
  <FormattedMessage
    id='hashtag.counter_by_uses_today'
    defaultMessage='{count, plural, one {{counter} post} other {{counter} posts}} today'
    values={{
      count: pluralReady,
      counter: <strong>{displayNumber}</strong>,
    }}
  />
);

export const HashtagHeader = withIdentity(injectIntl(({ tag, intl, disabled, onClick, identity }) => {
  if (!tag) {
    return null;
  }

  const { signedIn, permissions } = identity;
  const menu = [];

  if (signedIn && (permissions & PERMISSION_MANAGE_TAXONOMIES) === PERMISSION_MANAGE_TAXONOMIES ) {
    menu.push({ text: intl.formatMessage(messages.adminModeration, { name: tag.get("name") }), href: `/admin/tags/${tag.get('id')}` });
  }

  const [uses, people] = tag.get('history').reduce((arr, day) => [arr[0] + day.get('uses') * 1, arr[1] + day.get('accounts') * 1], [0, 0]);
  const dividingCircle = <span aria-hidden>{' · '}</span>;

  return (
    <div className='hashtag-header'>
      <div className='hashtag-header__header'>
        <h1>#{tag.get('name')}</h1>
        <div className='hashtag-header__header__buttons'>
          { menu.length > 0 && <DropdownMenuContainer disabled={menu.length === 0} items={menu} icon='ellipsis-v' iconComponent={MoreHorizIcon} size={24} direction='right' /> }
          <Button onClick={onClick} text={intl.formatMessage(tag.get('following') ? messages.unfollowHashtag : messages.followHashtag)} disabled={disabled} />
        </div>
      </div>

      <div>
        <ShortNumber value={uses} renderer={usesRenderer} />
        {dividingCircle}
        <ShortNumber value={people} renderer={peopleRenderer} />
        {dividingCircle}
        <ShortNumber value={tag.getIn(['history', 0, 'uses']) * 1} renderer={usesTodayRenderer} />
      </div>
    </div>
  );
}));

HashtagHeader.propTypes = {
  tag: ImmutablePropTypes.map,
  disabled: PropTypes.bool,
  onClick: PropTypes.func,
  intl: PropTypes.object,
};
