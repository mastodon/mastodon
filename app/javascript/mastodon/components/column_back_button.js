import React from 'react';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';
import Icon from 'mastodon/components/icon';
import { createPortal } from 'react-dom';

export default class ColumnBackButton extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    multiColumn: PropTypes.bool,
  };

  handleClick = () => {
    if (window.history && window.history.length === 1) {
      this.context.router.history.push('/');
    } else {
      this.context.router.history.goBack();
    }
  }

  render () {
    const { multiColumn } = this.props;

    const component = (
      <button onClick={this.handleClick} className='column-back-button'>
        <Icon id='chevron-left' className='column-back-button__icon' fixedWidth />
        <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
      </button>
    );

    if (multiColumn) {
      return component;
    } else {
      return createPortal(component, document.getElementById('tabs-bar__portal'));
    }
  }

}
