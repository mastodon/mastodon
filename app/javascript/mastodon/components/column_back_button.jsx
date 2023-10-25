import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import { withRouter } from 'react-router-dom';

import { ReactComponent as ArrowBackIcon } from '@material-symbols/svg-600/outlined/arrow_back.svg';

import { Icon }  from 'mastodon/components/icon';
import { ButtonInTabsBar } from 'mastodon/features/ui/util/columns_context';
import { WithRouterPropTypes } from 'mastodon/utils/react_router';

export class ColumnBackButton extends PureComponent {

  static propTypes = {
    onClick: PropTypes.func,
    ...WithRouterPropTypes,
  };

  handleClick = () => {
    const { onClick, history } = this.props;

    if (onClick) {
      onClick();
    } else if (history.location?.state?.fromMastodon) {
      history.goBack();
    } else {
      history.push('/');
    }
  };

  render () {
    const component = (
      <button onClick={this.handleClick} className='column-back-button'>
        <Icon id='chevron-left' icon={ArrowBackIcon} className='column-back-button__icon' />
        <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
      </button>
    );

    return <ButtonInTabsBar component={component} />;
  }
}

export default withRouter(ColumnBackButton);
