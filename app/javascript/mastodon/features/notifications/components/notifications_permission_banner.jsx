import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { connect } from 'react-redux';

import SettingsIcon from '@/material-icons/400-20px/settings.svg?react';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { requestBrowserPermission } from 'mastodon/actions/notifications';
import { changeSetting } from 'mastodon/actions/settings';
import { Button } from 'mastodon/components/button';
import { Icon }  from 'mastodon/components/icon';
import { IconButton } from 'mastodon/components/icon_button';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

class NotificationsPermissionBanner extends PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleClick = () => {
    this.props.dispatch(requestBrowserPermission());
  };

  handleClose = () => {
    this.props.dispatch(changeSetting(['notifications', 'dismissPermissionBanner'], true));
  };

  render () {
    const { intl } = this.props;

    return (
      <div className='notifications-permission-banner'>
        <div className='notifications-permission-banner__close'>
          <IconButton icon='times' iconComponent={CloseIcon} onClick={this.handleClose} title={intl.formatMessage(messages.close)} />
        </div>

        <h2><FormattedMessage id='notifications_permission_banner.title' defaultMessage='Never miss a thing' /></h2>
        <p><FormattedMessage id='notifications_permission_banner.how_to_control' defaultMessage="To receive notifications when Mastodon isn't open, enable desktop notifications. You can control precisely which types of interactions generate desktop notifications through the {icon} button above once they're enabled." values={{ icon: <Icon id='sliders' icon={SettingsIcon} /> }} /></p>
        <Button onClick={this.handleClick}><FormattedMessage id='notifications_permission_banner.enable' defaultMessage='Enable desktop notifications' /></Button>
      </div>
    );
  }

}

export default connect()(injectIntl(NotificationsPermissionBanner));
