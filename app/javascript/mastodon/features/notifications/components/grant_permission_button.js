import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';

export default class GrantPermissionButton extends React.PureComponent {

  static propTypes = {
    onClick: PropTypes.func.isRequired,
  };

  render () {
    return (
      <button className='text-btn column-header__permission-btn' tabIndex='0' onClick={this.props.onClick}>
        <FormattedMessage id='notifications.grant_permission' defaultMessage='Grant permission.' />
      </button>
    );
  }

}
