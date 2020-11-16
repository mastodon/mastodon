import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import Icon from 'mastodon/components/icon';

export default class GrantPermissionButton extends React.PureComponent {

  static propTypes = {
    onClick: PropTypes.func.isRequired,
  };

  render () {
    return (
      <button className='text-btn column-header__setting-btn' tabIndex='0' onClick={this.props.onClick}>
        <Icon id='sliders' /> <FormattedMessage id='notifications.grant_permission' defaultMessage='Grant permission' />
      </button>
    );
  }

}
