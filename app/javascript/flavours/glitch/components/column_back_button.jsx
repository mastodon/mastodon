import PropTypes from 'prop-types';
import { PureComponent } from 'react';
import { createPortal } from 'react-dom';

import { FormattedMessage } from 'react-intl';

import { Icon } from 'flavours/glitch/components/icon';


export default class ColumnBackButton extends PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    multiColumn: PropTypes.bool,
  };

  handleClick = () => {
    const { router } = this.context;

    if (router.history.location?.state?.fromMastodon) {
      router.history.goBack();
    } else {
      router.history.push('/');
    }
  };

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
