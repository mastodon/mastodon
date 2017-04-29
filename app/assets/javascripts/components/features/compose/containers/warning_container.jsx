import { connect } from 'react-redux';
import Warning from '../components/warning';
import { createSelector } from 'reselect';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';

const getMentionedUsernames = createSelector(state => state.getIn(['compose', 'text']), text => text.match(/(?:^|[^\/\w])@([a-z0-9_]+@[a-z0-9\.\-]+)/ig));

const getMentionedDomains = createSelector(getMentionedUsernames, mentionedUsernamesWithDomains => {
  return mentionedUsernamesWithDomains !== null ? [...new Set(mentionedUsernamesWithDomains.map(item => item.split('@')[2]))] : [];
});

const mapStateToProps = state => {
  const mentionedUsernames = getMentionedUsernames(state);
  const mentionedUsernamesWithDomains = getMentionedDomains(state);

  return {
    needsLeakWarning: (state.getIn(['compose', 'privacy']) === 'private' || state.getIn(['compose', 'privacy']) === 'direct') && mentionedUsernames !== null,
    mentionedDomains: mentionedUsernamesWithDomains,
    needsLockWarning: state.getIn(['compose', 'privacy']) === 'private' && !state.getIn(['accounts', state.getIn(['meta', 'me']), 'locked'])
  };
};

const WarningWrapper = ({ needsLeakWarning, needsLockWarning, mentionedDomains }) => {
  if (needsLockWarning) {
    return <Warning message={<FormattedMessage id='compose_form.lock_disclaimer' defaultMessage='Your account is not {locked}. Anyone can follow you to view your follower-only posts.' values={{ locked: <a href='/settings/profile'><FormattedMessage id='compose_form.lock_disclaimer.lock' defaultMessage='locked' /></a> }} />} />;
  } else if (needsLeakWarning) {
    return (
      <Warning
        message={<FormattedMessage
          id='compose_form.privacy_disclaimer'
          defaultMessage='Your private status will be delivered to mentioned users on {domains}. Do you trust {domainsCount, plural, one {that server} other {those servers}} to not leak your status?'
          values={{ domains: <strong>{mentionedDomains.join(', ')}</strong>, domainsCount: mentionedDomains.length }}
        />}
      />
    );
  }

  return null;
};

WarningWrapper.propTypes = {
  needsLeakWarning: PropTypes.bool,
  needsLockWarning: PropTypes.bool,
  mentionedDomains: PropTypes.array.isRequired,
};

export default connect(mapStateToProps)(WarningWrapper);
