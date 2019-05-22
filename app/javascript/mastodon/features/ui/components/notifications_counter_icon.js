import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import Icon from 'mastodon/components/icon';

const mapStateToProps = state => ({
  count: state.getIn(['notifications', 'unread']),
});

const formatNumber = num => num > 99 ? '99+' : num;

const NotificationsCounterIcon = ({ count }) => (
  <i className='icon-with-badge'>
    <Icon id='bell' fixedWidth />
    {count > 0 && <i className='icon-with-badge__badge'>{formatNumber(count)}</i>}
  </i>
);

NotificationsCounterIcon.propTypes = {
  count: PropTypes.number.isRequired,
};

export default connect(mapStateToProps)(NotificationsCounterIcon);
