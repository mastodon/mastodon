import React from 'react';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';
import { Icon }  from 'mastodon/components/icon';
import { createPortal } from 'react-dom';

export default class ColumnBackButton extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    multiColumn: PropTypes.bool,
    onClick: PropTypes.func,
  };

  handleClick = () => {
    const { router } = this.context;
    const { onClick } = this.props;

    if (onClick) {
      onClick();
    // Check if there is a previous page in the app to go back to per https://stackoverflow.com/a/70532858/9703201
    // When upgrading to V6, check `location.key !== 'default'` instead per https://github.com/remix-run/history/blob/main/docs/api-reference.md#location
    } else if (router.route.location.key) {
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
