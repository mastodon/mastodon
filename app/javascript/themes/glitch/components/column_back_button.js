import React from 'react';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';

export default class ColumnBackButton extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  handleClick = () => {
    // if history is exhausted, or we would leave mastodon, just go to root.
    if (window.history && (window.history.length === 1 || window.history.length === window._mastoInitialHistoryLen)) {
      this.context.router.history.push('/');
    } else {
      this.context.router.history.goBack();
    }
  }

  render () {
    return (
      <button onClick={this.handleClick} className='column-back-button'>
        <i className='fa fa-fw fa-chevron-left column-back-button__icon' />
        <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
      </button>
    );
  }

}
