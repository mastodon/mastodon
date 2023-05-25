import React from 'react';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';
import { Icon } from 'flavours/glitch/components/icon';

export default class ColumnBackButtonSlim extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  handleClick = () => {
    const { router } = this.context;

    // Check if there is a previous page in the app to go back to per https://stackoverflow.com/a/70532858/9703201
    // When upgrading to V6, check `location.key !== 'default'` instead per https://github.com/remix-run/history/blob/main/docs/api-reference.md#location
    if (router.route.location.key) {
      router.history.goBack();
    } else {
      router.history.push('/');
    }
  };

  render () {
    return (
      <div className='column-back-button--slim'>
        <div role='button' tabIndex={0} onClick={this.handleClick} className='column-back-button column-back-button--slim-button'>
          <Icon id='chevron-left' className='column-back-button__icon' fixedWidth />
          <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
        </div>
      </div>
    );
  }

}
