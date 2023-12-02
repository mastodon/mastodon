import React, { useCallback, useState } from 'react';

import { FormattedMessage, defineMessages, useIntl } from 'react-intl';
import type { IntlShape } from 'react-intl';

import classNames from 'classnames';
import type { RouteComponentProps } from 'react-router-dom';

import { ReactComponent as AddIcon } from '@material-symbols/svg-600/outlined/add.svg';
import { ReactComponent as ArrowBackIcon } from '@material-symbols/svg-600/outlined/arrow_back.svg';
import { ReactComponent as ChevronLeftIcon } from '@material-symbols/svg-600/outlined/chevron_left.svg';
import { ReactComponent as ChevronRightIcon } from '@material-symbols/svg-600/outlined/chevron_right.svg';
import { ReactComponent as CloseIcon } from '@material-symbols/svg-600/outlined/close.svg';
import { ReactComponent as TuneIcon } from '@material-symbols/svg-600/outlined/tune.svg';

import type { IconProp } from 'mastodon/components/icon';
import { Icon } from 'mastodon/components/icon';
import { useIdentityContext } from 'mastodon/containers/identity_context';
import {
  ButtonInTabsBar,
  useColumnsContext,
} from 'mastodon/features/ui/util/columns_context';

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

export const ColumnHeader = ({
  active,
  appendContent,
  children,
  collapseIssues,
  extraButton,
  icon,
  iconComponent,
  multiColumn,
  onClick,
  onMove,
  onPin,
  pinned,
  placeholder,
  showBackButton,
  title,
}: ColumnHeaderProps) => {
  const identity = useIdentityContext();
  const [animating, setAnimating] = useState(false);
  const [collapsed, setCollapsed] = useState(true);
  const intl = useIntl();
  const history = useAppHistory();

  const handleToggleClick = useCallback(
    (e: React.MouseEvent) => {
      e.stopPropagation();
      setCollapsed(!collapsed);
      setAnimating(true);
    },
    [collapsed],
  );

  const handleMoveLeft = useCallback(() => {
    // handleMoveLeft should only be used in situations where onMove is provided
    onMove?.(-1);
  }, [onMove]);

  const handleMoveRight = useCallback(() => {
    // handleMoveRight should only be used in situations where onMove is provided
    onMove?.(1);
  }, [onMove]);

  const handleTransitionEnd = useCallback(() => {
    setAnimating(false);
  }, []);

  const handlePin = useCallback(() => {
    if (!pinned) {
      history.replace('/');
    }

    // handlePin is only used if onPin is provided
    onPin?.();
  }, [history, onPin, pinned]);

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
        onClick={handlePin}
      >
        <Icon id='times' icon={CloseIcon} />{' '}
        <FormattedMessage id='column_header.unpin' defaultMessage='Unpin' />
      </button>
    );

    moveButtons = (
      <div key='move-buttons' className='column-header__setting-arrows'>
        <button
          title={intl.formatMessage(messages.moveLeft)}
          aria-label={intl.formatMessage(messages.moveLeft)}
          className='icon-button column-header__setting-btn'
          onClick={handleMoveLeft}
        >
          <Icon id='chevron-left' icon={ChevronLeftIcon} />
        </button>
        <button
          title={intl.formatMessage(messages.moveRight)}
          aria-label={intl.formatMessage(messages.moveRight)}
          className='icon-button column-header__setting-btn'
          onClick={handleMoveRight}
        >
          <Icon id='chevron-right' icon={ChevronRightIcon} />
        </button>
      </div>
    );
  } else if (multiColumn && onPin) {
    pinButton = (
      <button
        key='pin-button'
        className='text-btn column-header__setting-btn'
        onClick={handlePin}
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

  if (identity.signedIn && (children || (multiColumn && onPin))) {
    collapseButton = (
      <button
        className={collapsibleButtonClassName}
        title={intl.formatMessage(collapsed ? messages.show : messages.hide)}
        aria-label={intl.formatMessage(
          collapsed ? messages.show : messages.hide,
        )}
        onClick={handleToggleClick}
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
          <button onClick={onClick}>
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
        onTransitionEnd={handleTransitionEnd}
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
};
