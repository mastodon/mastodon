import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';
import ImmutablePropTypes from 'react-immutable-proptypes';

// Glitch imports
import NotificationPurgeButtonsContainer from '../../glitch/components/column/notif_cleaning_widget/container';

const messages = defineMessages({
  enterNotifCleaning : { id: 'notification_purge.start', defaultMessage: 'Enter notification cleaning mode' },
});

@injectIntl
export default class ColumnHeader extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    title: PropTypes.node.isRequired,
    icon: PropTypes.string.isRequired,
    active: PropTypes.bool,
    localSettings : ImmutablePropTypes.map,
    multiColumn: PropTypes.bool,
    showBackButton: PropTypes.bool,
    notifCleaning: PropTypes.bool, // true only for the notification column
    notifCleaningActive: PropTypes.bool,
    onEnterCleaningMode: PropTypes.func,
    children: PropTypes.node,
    pinned: PropTypes.bool,
    onPin: PropTypes.func,
    onMove: PropTypes.func,
    onClick: PropTypes.func,
    intl: PropTypes.object.isRequired,
  };

  state = {
    collapsed: true,
    animating: false,
    animatingNCD: false,
  };

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

  handleBackClick = () => {
    // if history is exhausted, or we would leave mastodon, just go to root.
    if (window.history && (window.history.length === 1 || window.history.length === window._mastoInitialHistoryLen)) {
      this.context.router.history.push('/');
    } else {
      this.context.router.history.goBack();
    }
  }

  handleTransitionEnd = () => {
    this.setState({ animating: false });
  }

  handleTransitionEndNCD = () => {
    this.setState({ animatingNCD: false });
  }

  onEnterCleaningMode = () => {
    this.setState({ animatingNCD: true });
    this.props.onEnterCleaningMode(!this.props.notifCleaningActive);
  }

  render () {
    const { intl, icon, active, children, pinned, onPin, multiColumn, showBackButton, notifCleaning, notifCleaningActive } = this.props;
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
      pinButton = <button key='pin-button' className='text-btn column-header__setting-btn' onClick={onPin}><i className='fa fa fa-times' /> <FormattedMessage id='column_header.unpin' defaultMessage='Unpin' /></button>;

      moveButtons = (
        <div key='move-buttons' className='column-header__setting-arrows'>
          <button className='text-btn column-header__setting-btn' onClick={this.handleMoveLeft}><i className='fa fa-chevron-left' /></button>
          <button className='text-btn column-header__setting-btn' onClick={this.handleMoveRight}><i className='fa fa-chevron-right' /></button>
        </div>
      );
    } else if (multiColumn) {
      pinButton = <button key='pin-button' className='text-btn column-header__setting-btn' onClick={onPin}><i className='fa fa fa-plus' /> <FormattedMessage id='column_header.pin' defaultMessage='Pin' /></button>;
    }

    if (!pinned && (multiColumn || showBackButton)) {
      backButton = (
        <button onClick={this.handleBackClick} className='column-header__back-button'>
          <i className='fa fa-fw fa-chevron-left column-back-button__icon' />
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

    if (children || multiColumn) {
      collapseButton = <button className={collapsibleButtonClassName} onClick={this.handleToggleClick}><i className='fa fa-sliders' /></button>;
    }

    return (
      <div className={wrapperClassName}>
        <div role='button heading' tabIndex='0' className={buttonClassName} onClick={this.handleTitleClick}>
          <i className={`fa fa-fw fa-${icon} column-header__icon`} />
          {title}
          <div className='column-header__buttons'>
            {backButton}
            { notifCleaning ? (
              <button
                aria-label={msgEnterNotifCleaning}
                title={msgEnterNotifCleaning}
                onClick={this.onEnterCleaningMode}
                className={notifCleaningButtonClassName}
              >
                <i className='fa fa-eraser' />
              </button>
            ) : null}
            {collapseButton}
          </div>
        </div>

        { notifCleaning ? (
          <div className={notifCleaningDrawerClassName} onTransitionEnd={this.handleTransitionEndNCD}>
            <div className='column-header__collapsible-inner nopad-drawer'>
              {(notifCleaningActive || animatingNCD) ? (<NotificationPurgeButtonsContainer />) : null }
            </div>
          </div>
        ) : null}

        <div className={collapsibleClassName} onTransitionEnd={this.handleTransitionEnd}>
          <div className='column-header__collapsible-inner'>
            {(!collapsed || animating) && collapsedContent}
          </div>
        </div>
      </div>
    );
  }

}
