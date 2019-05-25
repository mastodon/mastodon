import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import Icon from 'flavours/glitch/components/icon';

const mapStateToProps = state => ({
  count: state.getIn(['notifications', 'unread']),
  showBadge: state.getIn(['local_settings', 'notifications', 'tab_badge']),
});

const formatNumber = num => num > 99 ? '99+' : num;

const NotificationsCounterIcon = ({ count, className, showBadge }) => (
  <i className='icon-with-badge'>
    <Icon icon='bell' fixedWidth className={className} />
    {showBadge && count > 0 && <i className='icon-with-badge__badge'>{formatNumber(count)}</i>}
  </i>
);

NotificationsCounterIcon.propTypes = {
  count: PropTypes.number.isRequired,
  showBadge: PropTypes.bool,
  className: PropTypes.string,
};

export default connect(mapStateToProps)(NotificationsCounterIcon);
