import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';

export default class ClearColumnButton extends React.Component {

  static propTypes = {
    onClick: PropTypes.func.isRequired,
  };

  render () {
    return (
      <button className='text-btn column-header__setting-btn' tabIndex='0' onClick={this.props.onClick}><i className='fa fa-eraser' /> <FormattedMessage id='notifications.clear' defaultMessage='Clear notifications' /></button>
    );
  }

}
