import React from 'react';
import Icon from 'flavours/glitch/components/icon';
import Button from 'flavours/glitch/components/button';
import { requestBrowserPermission } from 'flavours/glitch/actions/notifications';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';

export default @connect(() => {})
class NotificationsPermissionBanner extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
  };

  handleClick = () => {
    this.props.dispatch(requestBrowserPermission());
  }

  render () {
    return (
      <div className='notifications-permission-banner'>
        <h2><FormattedMessage id='notifications_permission_banner.title' defaultMessage='Never miss a thing' /></h2>
        <p><FormattedMessage id='notifications_permission_banner.how_to_control' defaultMessage="To receive notifications when Mastodon isn't open, enable desktop notifications. You can control precisely which types of interactions generate desktop notifications through the {icon} button above once they're enabled." values={{ icon: <Icon id='sliders' /> }} /></p>
        <Button onClick={this.handleClick}><FormattedMessage id='notifications_permission_banner.enable' defaultMessage='Enable desktop notifications' /></Button>
      </div>
    );
  }

}
