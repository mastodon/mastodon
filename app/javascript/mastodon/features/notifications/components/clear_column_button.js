import React from 'react';
import PropTypes from 'prop-types';
import { injectIntl, FormattedMessage } from 'react-intl';

class ClearColumnButton extends React.Component {

  static propTypes = {
    onClick: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { intl } = this.props;

    return (
      <button
        className='text-btn column-header__setting-btn'
        tabIndex='0'
        onClick={this.props.onClick}
      >
        <i className='fa fa-eraser' />
        {' '}
        <FormattedMessage id='notifications.clear' defaultMessage='Clear notifications' />
      </button>
    );
  }

}

export default injectIntl(ClearColumnButton);
