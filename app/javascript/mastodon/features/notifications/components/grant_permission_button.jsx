import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

export default class GrantPermissionButton extends PureComponent {

  static propTypes = {
    onClick: PropTypes.func.isRequired,
  };

  render () {
    return (
      <button className='text-btn column-header__permission-btn' tabIndex={0} onClick={this.props.onClick}>
        <FormattedMessage id='notifications.grant_permission' defaultMessage='Grant permission.' />
      </button>
    );
  }

}
