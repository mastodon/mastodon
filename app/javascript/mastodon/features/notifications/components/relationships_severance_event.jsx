import PropTypes from 'prop-types';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';

import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';

// This needs to be kept in sync with app/models/relationship_severance_event.rb
const messages = defineMessages({
  account_suspension: { id: 'relationship_severance_notification.types.account_suspension', defaultMessage: 'Account has been suspended' },
  domain_block: { id: 'relationship_severance_notification.types.domain_block', defaultMessage: 'Domain has been suspended' },
  user_domain_block: { id: 'relationship_severance_notification.types.user_domain_block', defaultMessage: 'You blocked this domain' },
});

const RelationshipsSeveranceEvent = ({ event, hidden }) => {
  const intl = useIntl();

  if (hidden || !event) {
    return null;
  }

  return (
    <div className='notification__report'>
      <div className='notification__report__details'>
        <div>
          <RelativeTimestamp timestamp={event.get('created_at')} short={false} />
          {' · '}
          { event.get('purged') ? (
            <FormattedMessage
              id='relationship_severance_notification.purged_data'
              defaultMessage='purged by administrators'
            />
          ) : (
            <FormattedMessage
              id='relationship_severance_notification.relationships'
              defaultMessage='{count, plural, one {# relationship} other {# relationships}}'
              values={{ count: event.get('followers_count', 0) + event.get('following_count', 0) }}
            />
          )}
          <br />
          <strong>{intl.formatMessage(messages[event.get('type')])}</strong>
        </div>

        <div className='notification__report__actions'>
          <a href='/severed_relationships' className='button' target='_blank' rel='noopener noreferrer'>
            <FormattedMessage id='relationship_severance_notification.view' defaultMessage='View' />
          </a>
        </div>
      </div>
    </div>
  );

};

RelationshipsSeveranceEvent.propTypes = {
  event: ImmutablePropTypes.map.isRequired,
  hidden: PropTypes.bool,
};

export default RelationshipsSeveranceEvent;
