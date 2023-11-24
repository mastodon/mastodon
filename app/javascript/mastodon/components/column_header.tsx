import PropTypes from 'prop-types';
import React, { PureComponent, useCallback } from 'react';

import { FormattedMessage, injectIntl, defineMessages } from 'react-intl';
import type { IntlShape } from 'react-intl';

import classNames from 'classnames';
import type { RouteComponentProps } from 'react-router-dom';
import { withRouter } from 'react-router-dom';

import { ReactComponent as AddIcon } from '@material-symbols/svg-600/outlined/add.svg';
import { ReactComponent as ArrowBackIcon } from '@material-symbols/svg-600/outlined/arrow_back.svg';
import { ReactComponent as ChevronLeftIcon } from '@material-symbols/svg-600/outlined/chevron_left.svg';
import { ReactComponent as ChevronRightIcon } from '@material-symbols/svg-600/outlined/chevron_right.svg';
import { ReactComponent as CloseIcon } from '@material-symbols/svg-600/outlined/close.svg';
import { ReactComponent as TuneIcon } from '@material-symbols/svg-600/outlined/tune.svg';

import type { IconProp } from 'mastodon/components/icon';
import { Icon } from 'mastodon/components/icon';
import {
  ButtonInTabsBar,
  useColumnsContext,
} from 'mastodon/features/ui/util/columns_context';
import type { ContextWithIdentity } from 'mastodon/utils/identity';

import { useAppHistory } from './router';

const messages = defineMessages({
  show: { id: 'column_header.show_settings', defaultMessage: 'Show settings' },
  hide: { id: 'column_header.hide_settings', defaultMessage: 'Hide settings' },
  moveLeft: {
    id: 'column_header.moveLeft_settings',
    defaultMessage: 'Move column to the left',
  },
  moveRight: {
    id: 'column_header.moveRight_settings',
    defaultMessage: 'Move column to the right',
  },
});

interface BackButtonProps {
  pinned?: boolean;
  show?: boolean;
}

const BackButton: React.FC<BackButtonProps> = ({ pinned, show }) => {
  const history = useAppHistory();
  const { multiColumn } = useColumnsContext();

  const handleBackClick = useCallback(() => {
    if (history.location.state?.fromMastodon) {
      history.goBack();
    } else {
      history.push('/');
    }
  }, [history]);

  const showButton =
    // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition
    history &&
    !pinned &&
    ((multiColumn && history.location.state?.fromMastodon) || show);

  if (!showButton) return null;

  return (
    <button onClick={handleBackClick} className='column-header__back-button'>
      <Icon
        id='chevron-left'
        icon={ArrowBackIcon}
        className='column-back-button__icon'
      />
      <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
    </button>
  );
};

interface ColumnHeaderProps extends RouteComponentProps {
  active?: boolean;
  appendContent?: React.ReactNode;
  children?: React.ReactNode;
  collapseIssues?: boolean;
  extraButton?: React.ReactNode;
  icon?: string;
  iconComponent?: IconProp;
  intl: IntlShape;
  multiColumn?: boolean;
  onClick?: () => void;
  onMove?: (direction: number) => void;
  onPin?: () => void;
  pinned?: boolean;
  placeholder?: boolean;
  showBackButton?: boolean;
  title?: React.ReactNode;
}

class ColumnHeaderInternal extends PureComponent<ColumnHeaderProps> {
  declare context: ContextWithIdentity;

  static contextTypes = {
    identity: PropTypes.object,
  };

  state = {
    collapsed: true,
    animating: false,
  };

  handleToggleClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    this.setState({ collapsed: !this.state.collapsed, animating: true });
  };

  handleTitleClick = () => {
    this.props.onClick?.();
  };

  handleMoveLeft = () => {
    // handleMoveLeft should only be used in situations where this.props.onMove is provided
    this.props.onMove?.(-1);
  };

  handleMoveRight = () => {
    // handleMoveRight should only be used in situations where this.props.onMove is provided
    this.props.onMove?.(1);
  };

  handleTransitionEnd = () => {
    this.setState({ animating: false });
  };

  handlePin = () => {
    if (!this.props.pinned) {
      this.props.history.replace('/');
    }

    // handlePin is only used if this.props.onPin is provided
    this.props.onPin?.();
  };

  render() {
    const {
      title,
      icon,
      iconComponent,
      active,
      children,
      pinned,
      multiColumn,
      extraButton,
      showBackButton,
      intl: { formatMessage },
      placeholder,
      appendContent,
      collapseIssues,
    } = this.props;
    const { collapsed, animating } = this.state;

    const wrapperClassName = classNames('column-header__wrapper', {
      active: active,
    });

    const buttonClassName = classNames('column-header', {
      active: active,
    });

    const collapsibleClassName = classNames('column-header__collapsible', {
      collapsed: collapsed,
      animating: animating,
    });

    const collapsibleButtonClassName = classNames('column-header__button', {
      active: !collapsed,
    });

    let extraContent, pinButton, moveButtons, collapseButton;

    if (children) {
      extraContent = (
        <div key='extra-content' className='column-header__collapsible__extra'>
          {children}
        </div>
      );
    }

    if (multiColumn && pinned) {
      pinButton = (
        <button
          key='pin-button'
          className='text-btn column-header__setting-btn'
          onClick={this.handlePin}
        >
          <Icon id='times' icon={CloseIcon} />{' '}
          <FormattedMessage id='column_header.unpin' defaultMessage='Unpin' />
        </button>
      );

      moveButtons = (
        <div key='move-buttons' className='column-header__setting-arrows'>
          <button
            title={formatMessage(messages.moveLeft)}
            aria-label={formatMessage(messages.moveLeft)}
            className='icon-button column-header__setting-btn'
            onClick={this.handleMoveLeft}
          >
            <Icon id='chevron-left' icon={ChevronLeftIcon} />
          </button>
          <button
            title={formatMessage(messages.moveRight)}
            aria-label={formatMessage(messages.moveRight)}
            className='icon-button column-header__setting-btn'
            onClick={this.handleMoveRight}
          >
            <Icon id='chevron-right' icon={ChevronRightIcon} />
          </button>
        </div>
      );
    } else if (multiColumn && this.props.onPin) {
      pinButton = (
        <button
          key='pin-button'
          className='text-btn column-header__setting-btn'
          onClick={this.handlePin}
        >
          <Icon id='plus' icon={AddIcon} />{' '}
          <FormattedMessage id='column_header.pin' defaultMessage='Pin' />
        </button>
      );
    }

    const backButton = <BackButton pinned={pinned} show={showBackButton} />;

    const collapsedContent = [extraContent];

    if (multiColumn) {
      collapsedContent.push(pinButton);
      collapsedContent.push(moveButtons);
    }

    if (
      this.context.identity.signedIn &&
      (children || (multiColumn && this.props.onPin))
    ) {
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

    const hasTitle = (icon ?? iconComponent) && title;

    const component = (
      <div className={wrapperClassName}>
        <h1 className={buttonClassName}>
          {hasTitle && (
            <button onClick={this.handleTitleClick}>
              <Icon
                // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
                id={icon!}
                // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
                icon={iconComponent!}
                className='column-header__icon'
              />
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

        <div
          className={collapsibleClassName}
          tabIndex={collapsed ? -1 : undefined}
          onTransitionEnd={this.handleTransitionEnd}
        >
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
      return <ButtonInTabsBar>{component}</ButtonInTabsBar>;
    }
  }
}

export const ColumnHeader = injectIntl(withRouter(ColumnHeaderInternal));
