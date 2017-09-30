import React from 'react';
import { connect } from 'react-redux';
import Warning from '../components/warning';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';

const mapStateToProps = state => ({
  needsLockWarning: state.getIn(['compose', 'privacy']) === 'private' && !state.getIn(['accounts', state.getIn(['meta', 'me']), 'locked']),
});

const WarningWrapper = ({ needsLockWarning }) => {
  if (needsLockWarning) {
    return <Warning message={<FormattedMessage id='compose_form.lock_disclaimer' defaultMessage='Your account is not {locked}. Anyone can follow you to view your follower-only posts.' values={{ locked: <a href='/settings/profile'><FormattedMessage id='compose_form.lock_disclaimer.lock' defaultMessage='locked' /></a> }} />} />;
  }

  return null;
};

WarningWrapper.propTypes = {
  needsLockWarning: PropTypes.bool,
};

export default connect(mapStateToProps)(WarningWrapper);
