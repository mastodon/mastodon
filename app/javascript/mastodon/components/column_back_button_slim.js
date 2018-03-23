import React from 'react';
import { FormattedMessage } from 'react-intl';
import ColumnBackButton from './column_back_button';

export default class ColumnBackButtonSlim extends ColumnBackButton {

  render () {
    return (
      <div className='column-back-button--slim'>
        <div role='button' tabIndex='0' onClick={this.handleClick} className='column-back-button column-back-button--slim-button'>
          <i className='fa fa-fw fa-chevron-left column-back-button__icon' />
          <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
        </div>
      </div>
    );
  }

}
