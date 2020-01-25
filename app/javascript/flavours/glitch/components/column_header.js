import React from 'react';
import PropTypes from 'prop-types';
import { createPortal } from 'react-dom';
import classNames from 'classnames';
import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Icon from 'flavours/glitch/components/icon';

import NotificationPurgeButtonsContainer from 'flavours/glitch/containers/notification_purge_buttons_container';

const messages = defineMessages({
  show: { id: 'column_header.show_settings', defaultMessage: 'Show settings' },
  hide: { id: 'column_header.hide_settings', defaultMessage: 'Hide settings' },
  moveLeft: { id: 'column_header.moveLeft_settings', defaultMessage: 'Move column to the left' },
  moveRight: { id: 'column_header.moveRight_settings', defaultMessage: 'Move column to the right' },
  enterNotifCleaning : { id: 'notification_purge.start', defaultMessage: 'Enter notification cleaning mode' },
});

export default @injectIntl
class ColumnHeader extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
    title: PropTypes.node,
    icon: PropTypes.string,
    active: PropTypes.bool,
    localSettings : ImmutablePropTypes.map,
    multiColumn: PropTypes.bool,
    extraButton: PropTypes.node,
    showBackButton: PropTypes.bool,
    notifCleaning: PropTypes.bool, // true only for the notification column
    notifCleaningActive: PropTypes.bool,
    onEnterCleaningMode: PropTypes.func,
    children: PropTypes.node,
    pinned: PropTypes.bool,
    placeholder: PropTypes.bool,
    onPin: PropTypes.func,
    onMove: PropTypes.func,
    onClick: PropTypes.func,
    intl: PropTypes.object.isRequired,
    appendContent: PropTypes.node,
  };

  state = {
    collapsed: true,
    animating: false,
    animatingNCD: false,
  };

  historyBack = (skip) => {
    // if history is exhausted, or we would leave mastodon, just go to root.
    if (window.history.state) {
      const state = this.context.router.history.location.state;
      if (skip && state && state.mastodonBackSteps) {
        this.context.router.history.go(-state.mastodonBackSteps);
      } else {
        this.context.router.history.goBack();
      }
    } else {
      this.context.router.history.push('/');
    }
  }

  handleToggleClick = (e) => {
    e.stopPropagation();
    this.setState({ collapsed: !this.state.collapsed, animating: true });
  }

  handleTitleClick = () => {
    this.props.onClick();
  }

  handleMoveLeft = () => {
    this.props.onMove(-1);
  }

  handleMoveRight = () => {
    this.props.onMove(1);
  }

  handleBackClick = (event) => {
    this.historyBack(event.shiftKey);
  }

  handleTransitionEnd = () => {
    this.setState({ animating: false });
  }

  handleTransitionEndNCD = () => {
    this.setState({ animatingNCD: false });
  }

  handlePin = () => {
    if (!this.props.pinned) {
      this.historyBack();
    }
    this.props.onPin();
  }

  onEnterCleaningMode = () => {
    this.setState({ animatingNCD: true });
    this.props.onEnterCleaningMode(!this.props.notifCleaningActive);
  }

  render () {
    const { intl, icon, active, children, pinned, multiColumn, extraButton, showBackButton, intl: { formatMessage }, notifCleaning, notifCleaningActive, placeholder, appendContent } = this.props;
    const { collapsed, animating, animatingNCD } = this.state;

    let title = this.props.title;

    const wrapperClassName = classNames('column-header__wrapper', {
      'active': active,
    });

    const buttonClassName = classNames('column-header', {
      'active': active,
    });

    const collapsibleClassName = classNames('column-header__collapsible', {
      'collapsed': collapsed,
      'animating': animating,
    });

    const collapsibleButtonClassName = classNames('column-header__button', {
      'active': !collapsed,
    });

    const notifCleaningButtonClassName = classNames('column-header__button', {
      'active': notifCleaningActive,
    });

    const notifCleaningDrawerClassName = classNames('ncd column-header__collapsible', {
      'collapsed': !notifCleaningActive,
      'animating': animatingNCD,
    });

    let extraContent, pinButton, moveButtons, backButton, collapseButton;

    //*glitch
    const msgEnterNotifCleaning = intl.formatMessage(messages.enterNotifCleaning);

    if (children) {
      extraContent = (
        <div key='extra-content' className='column-header__collapsible__extra'>
          {children}
        </div>
      );
    }

    if (multiColumn && pinned) {
      pinButton = <button key='pin-button' className='text-btn column-header__setting-btn' onClick={this.handlePin}><Icon id='times' /> <FormattedMessage id='column_header.unpin' defaultMessage='Unpin' /></button>;

      moveButtons = (
        <div key='move-buttons' className='column-header__setting-arrows'>
          <button title={formatMessage(messages.moveLeft)} aria-label={formatMessage(messages.moveLeft)} className='text-btn column-header__setting-btn' onClick={this.handleMoveLeft}><Icon id='chevron-left' /></button>
          <button title={formatMessage(messages.moveRight)} aria-label={formatMessage(messages.moveRight)} className='text-btn column-header__setting-btn' onClick={this.handleMoveRight}><Icon id='chevron-right' /></button>
        </div>
      );
    } else if (multiColumn && this.props.onPin) {
      pinButton = <button key='pin-button' className='text-btn column-header__setting-btn' onClick={this.handlePin}><Icon id='plus' /> <FormattedMessage id='column_header.pin' defaultMessage='Pin' /></button>;
    }

    if (!pinned && (multiColumn || showBackButton)) {
      backButton = (
        <button onClick={this.handleBackClick} className='column-header__back-button'>
          <Icon id='chevron-left' className='column-back-button__icon' fixedWidth />
          <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
        </button>
      );
    }

    const collapsedContent = [
      extraContent,
    ];

    if (multiColumn) {
      collapsedContent.push(moveButtons);
      collapsedContent.push(pinButton);
    }

    if (children || (multiColumn && this.props.onPin)) {
      collapseButton = <button className={collapsibleButtonClassName} title={formatMessage(collapsed ? messages.show : messages.hide)} aria-label={formatMessage(collapsed ? messages.show : messages.hide)} aria-pressed={collapsed ? 'false' : 'true'} onClick={this.handleToggleClick}><Icon id='sliders' /></button>;
    }

    const hasTitle = icon && title;

    const component = (
      <div className={wrapperClassName}>
        <h1 className={buttonClassName}>
          {hasTitle && (
            <button onClick={this.handleTitleClick}>
              <Icon id={icon} fixedWidth className='column-header__icon' />
              {title}
            </button>
          )}

          {!hasTitle && backButton}

          <div className='column-header__buttons'>
            {hasTitle && backButton}
            {extraButton}
            { notifCleaning ? (
              <button
                aria-label={msgEnterNotifCleaning}
                title={msgEnterNotifCleaning}
                onClick={this.onEnterCleaningMode}
                className={notifCleaningButtonClassName}
              >
                <Icon id='eraser' />
              </button>
            ) : null}
            {collapseButton}
          </div>
        </h1>

        { notifCleaning ? (
          <div className={notifCleaningDrawerClassName} onTransitionEnd={this.handleTransitionEndNCD}>
            <div className='column-header__collapsible-inner nopad-drawer'>
              {(notifCleaningActive || animatingNCD) ? (<NotificationPurgeButtonsContainer />) : null }
            </div>
          </div>
        ) : null}

        <div className={collapsibleClassName} tabIndex={collapsed ? -1 : null} onTransitionEnd={this.handleTransitionEnd}>
          <div className='column-header__collapsible-inner'>
            {(!collapsed || animating) && collapsedContent}
          </div>
        </div>

        {appendContent}
      </div>
    );

    if (multiColumn || placeholder) {
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
