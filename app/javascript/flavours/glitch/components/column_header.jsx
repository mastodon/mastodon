import PropTypes from 'prop-types';
import { PureComponent, useCallback } from 'react';

import { FormattedMessage, injectIntl, defineMessages } from 'react-intl';

import classNames from 'classnames';
import { withRouter } from 'react-router-dom';

import AddIcon from '@/material-icons/400-24px/add.svg?react';
import ArrowBackIcon from '@/material-icons/400-24px/arrow_back.svg?react';
import ChevronLeftIcon from '@/material-icons/400-24px/chevron_left.svg?react';
import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import TuneIcon from '@/material-icons/400-24px/tune.svg?react';
import { Icon }  from 'flavours/glitch/components/icon';
import { ButtonInTabsBar, useColumnsContext } from 'flavours/glitch/features/ui/util/columns_context';
import { WithRouterPropTypes } from 'flavours/glitch/utils/react_router';


import { useAppHistory } from './router';

const messages = defineMessages({
  show: { id: 'column_header.show_settings', defaultMessage: 'Show settings' },
  hide: { id: 'column_header.hide_settings', defaultMessage: 'Hide settings' },
  moveLeft: { id: 'column_header.moveLeft_settings', defaultMessage: 'Move column to the left' },
  moveRight: { id: 'column_header.moveRight_settings', defaultMessage: 'Move column to the right' },
});

const BackButton = ({ pinned, show }) => {
  const history = useAppHistory();
  const { multiColumn } = useColumnsContext();

  const handleBackClick = useCallback(() => {
    if (history.location?.state?.fromMastodon) {
      history.goBack();
    } else {
      history.push('/');
    }
  }, [history]);

  const showButton = history && !pinned && ((multiColumn && history.location?.state?.fromMastodon) || show);

  if(!showButton) return null;

  return (<button onClick={handleBackClick} className='column-header__back-button'>
    <Icon id='chevron-left' icon={ArrowBackIcon} className='column-back-button__icon' />
    <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
  </button>);

};

BackButton.propTypes = {
  pinned: PropTypes.bool,
  show: PropTypes.bool,
};

class ColumnHeader extends PureComponent {

  static contextTypes = {
    identity: PropTypes.object,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
    title: PropTypes.node,
    icon: PropTypes.string,
    iconComponent: PropTypes.func,
    active: PropTypes.bool,
    multiColumn: PropTypes.bool,
    extraButton: PropTypes.node,
    showBackButton: PropTypes.bool,
    children: PropTypes.node,
    pinned: PropTypes.bool,
    placeholder: PropTypes.bool,
    onPin: PropTypes.func,
    onMove: PropTypes.func,
    onClick: PropTypes.func,
    appendContent: PropTypes.node,
    collapseIssues: PropTypes.bool,
    ...WithRouterPropTypes,
  };

  state = {
    collapsed: true,
    animating: false,
  };

  handleToggleClick = (e) => {
    e.stopPropagation();
    this.setState({ collapsed: !this.state.collapsed, animating: true });
  };

  handleTitleClick = () => {
    this.props.onClick?.();
  };

  handleMoveLeft = () => {
    this.props.onMove(-1);
  };

  handleMoveRight = () => {
    this.props.onMove(1);
  };

  handleTransitionEnd = () => {
    this.setState({ animating: false });
  };

  handlePin = () => {
    if (!this.props.pinned) {
      this.props.history.replace('/');
    }

    this.props.onPin();
  };

  render () {
    const { title, icon, iconComponent, active, children, pinned, multiColumn, extraButton, showBackButton, intl: { formatMessage }, placeholder, appendContent, collapseIssues } = this.props;
    const { collapsed, animating } = this.state;

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

    let extraContent, pinButton, moveButtons, backButton, collapseButton;

    if (children) {
      extraContent = (
        <div key='extra-content' className='column-header__collapsible__extra'>
          {children}
        </div>
      );
    }

    if (multiColumn && pinned) {
      pinButton = <button key='pin-button' className='text-btn column-header__setting-btn' onClick={this.handlePin}><Icon id='times' icon={CloseIcon} /> <FormattedMessage id='column_header.unpin' defaultMessage='Unpin' /></button>;

      moveButtons = (
        <div key='move-buttons' className='column-header__setting-arrows'>
          <button title={formatMessage(messages.moveLeft)} aria-label={formatMessage(messages.moveLeft)} className='icon-button column-header__setting-btn' onClick={this.handleMoveLeft}><Icon id='chevron-left' icon={ChevronLeftIcon} /></button>
          <button title={formatMessage(messages.moveRight)} aria-label={formatMessage(messages.moveRight)} className='icon-button column-header__setting-btn' onClick={this.handleMoveRight}><Icon id='chevron-right' icon={ChevronRightIcon} /></button>
        </div>
      );
    } else if (multiColumn && this.props.onPin) {
      pinButton = <button key='pin-button' className='text-btn column-header__setting-btn' onClick={this.handlePin}><Icon id='plus' icon={AddIcon} /> <FormattedMessage id='column_header.pin' defaultMessage='Pin' /></button>;
    }

    backButton = <BackButton pinned={pinned} show={showBackButton} />;

    const collapsedContent = [
      extraContent,
    ];

    if (multiColumn) {
      collapsedContent.push(pinButton);
      collapsedContent.push(moveButtons);
    }

    if (this.context.identity.signedIn && (children || (multiColumn && this.props.onPin))) {
      collapseButton = (
        <button
          className={collapsibleButtonClassName}
          title={formatMessage(collapsed ? messages.show : messages.hide)}
          aria-label={formatMessage(collapsed ? messages.show : messages.hide)}
          onClick={this.handleToggleClick}
        >
          <i className='icon-with-badge'>
            <Icon id='sliders' icon={TuneIcon} />
            {collapseIssues && <i className='icon-with-badge__issue-badge' />}
          </i>
        </button>
      );
    }

    const hasTitle = (icon || iconComponent) && title;

    const component = (
      <div className={wrapperClassName}>
        <h1 className={buttonClassName}>
          {hasTitle && (
            <button onClick={this.handleTitleClick}>
              <Icon id={icon} icon={iconComponent} className='column-header__icon' />
              {title}
            </button>
          )}

          {!hasTitle && backButton}

          <div className='column-header__buttons'>
            {hasTitle && backButton}
            {extraButton}
            {collapseButton}
          </div>
        </h1>

        <div className={collapsibleClassName} tabIndex={collapsed ? -1 : null} onTransitionEnd={this.handleTransitionEnd}>
          <div className='column-header__collapsible-inner'>
            {(!collapsed || animating) && collapsedContent}
          </div>
        </div>

        {appendContent}
      </div>
    );

    if (placeholder) {
      return component;
    } else {
      return (<ButtonInTabsBar>
        {component}
      </ButtonInTabsBar>);
    }
  }

}

export default injectIntl(withRouter(ColumnHeader));
