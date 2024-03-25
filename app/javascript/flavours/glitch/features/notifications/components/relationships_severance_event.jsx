import PropTypes from 'prop-types';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import HeartBrokenIcon from '@/material-icons/400-24px/heart_broken-fill.svg?react';
import { Icon }  from 'flavours/glitch/components/icon';
import { domain } from 'flavours/glitch/initial_state';

// This needs to be kept in sync with app/models/relationships_severance_event.rb
const messages = defineMessages({
  account_suspension: { id: 'notification.relationships_severance_event.account_suspension', defaultMessage: 'An admin from {from} has suspended {target}, which means you can no longer receive updates from them or interact with them.' },
  domain_block: { id: 'notification.relationships_severance_event.domain_block', defaultMessage: 'An admin from {from} has blocked {target}, including {followersCount} of your followers and {followingCount, plural, one {# account} other {# accounts}} you follow.' },
  user_domain_block: { id: 'notification.relationships_severance_event.user_domain_block', defaultMessage: 'You have blocked {target}, removing {followersCount} of your followers and {followingCount, plural, one {# account} other {# accounts}} you follow.' },
});

export const RelationshipsSeveranceEvent = ({ type, target, followingCount, followersCount, hidden }) => {
  const intl = useIntl();

  if (hidden) {
    return null;
  }

  return (
    <a href='/severed_relationships' target='_blank' rel='noopener noreferrer' className='notification__relationships-severance-event'>
      <Icon id='heart_broken' icon={HeartBrokenIcon} />

      <div className='notification__relationships-severance-event__content'>
        <p>{intl.formatMessage(messages[type], { from: <strong>{domain}</strong>, target: <strong>{target}</strong>, followingCount, followersCount })}</p>
        <span className='link-button'><FormattedMessage id='notification.relationships_severance_event.learn_more' defaultMessage='Learn more' /></span>
      </div>
    </a>
  );
};

RelationshipsSeveranceEvent.propTypes = {
  type: PropTypes.oneOf([
    'account_suspension',
    'domain_block',
    'user_domain_block',
  ]).isRequired,
  target: PropTypes.string.isRequired,
  followersCount: PropTypes.number.isRequired,
  followingCount: PropTypes.number.isRequired,
  hidden: PropTypes.bool,
};
