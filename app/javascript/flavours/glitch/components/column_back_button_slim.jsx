import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import { withRouter } from 'react-router-dom';

import { ReactComponent as ArrowBackIcon } from '@material-symbols/svg-600/outlined/arrow_back.svg';

import { Icon } from 'flavours/glitch/components/icon';
import { WithRouterPropTypes } from 'flavours/glitch/utils/react_router';

class ColumnBackButtonSlim extends PureComponent {

  static propTypes = {
    ...WithRouterPropTypes,
  };

  handleClick = () => {
    const { location, history } = this.props;

    // Check if there is a previous page in the app to go back to per https://stackoverflow.com/a/70532858/9703201
    // When upgrading to V6, check `location.key !== 'default'` instead per https://github.com/remix-run/history/blob/main/docs/api-reference.md#location
    if (location.key) {
      history.goBack();
    } else {
      history.push('/');
    }
  };

  render () {
    return (
      <div className='column-back-button--slim'>
        <div role='button' tabIndex={0} onClick={this.handleClick} className='column-back-button column-back-button--slim-button'>
          <Icon id='chevron-left' icon={ArrowBackIcon} className='column-back-button__icon' />
          <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
        </div>
      </div>
    );
  }
}

export default withRouter(ColumnBackButtonSlim);
