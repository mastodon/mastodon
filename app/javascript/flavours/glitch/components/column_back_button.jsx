import PropTypes from 'prop-types';
import { PureComponent } from 'react';
import { createPortal } from 'react-dom';

import { FormattedMessage } from 'react-intl';

import { withRouter } from 'react-router-dom';

import { ReactComponent as ArrowBackIcon } from '@material-symbols/svg-600/outlined/arrow_back.svg';

import { Icon }  from 'flavours/glitch/components/icon';
import { WithRouterPropTypes } from 'flavours/glitch/utils/react_router';

export class ColumnBackButton extends PureComponent {

  static propTypes = {
    multiColumn: PropTypes.bool,
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
    const { multiColumn } = this.props;

    const component = (
      <button onClick={this.handleClick} className='column-back-button'>
        <Icon id='chevron-left' icon={ArrowBackIcon} className='column-back-button__icon' />
        <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
      </button>
    );

    if (multiColumn) {
      return component;
    } else {
      // The portal container and the component may be rendered to the DOM in
      // the same React render pass, so the container might not be available at
      // the time `render()` is called.
      const container = document.getElementById('tabs-bar__portal');
      if (container === null) {
        // The container wasn't available, force a re-render so that the
        // component can eventually be inserted in the container and not scroll
        // with the rest of the area.
        this.forceUpdate();
        return component;
      } else {
        return createPortal(component, container);
      }
    }
  }

}

export default withRouter(ColumnBackButton);
