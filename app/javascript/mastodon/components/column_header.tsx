import { useCallback, useState } from 'react';

import { FormattedMessage, defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import AddIcon from '@/material-icons/400-24px/add.svg?react';
import ArrowBackIcon from '@/material-icons/400-24px/arrow_back.svg?react';
import ChevronLeftIcon from '@/material-icons/400-24px/chevron_left.svg?react';
import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import SettingsIcon from '@/material-icons/400-24px/settings.svg?react';
import type { IconProp } from 'mastodon/components/icon';
import { Icon } from 'mastodon/components/icon';
import { ButtonInTabsBar } from 'mastodon/features/ui/util/columns_context';
import { useIdentity } from 'mastodon/identity_context';

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
  back: { id: 'column_back_button.label', defaultMessage: 'Back' },
});

const BackButton: React.FC<{
  onlyIcon: boolean;
}> = ({ onlyIcon }) => {
  const history = useAppHistory();
  const intl = useIntl();

  const handleBackClick = useCallback(() => {
    if (history.location.state?.fromMastodon) {
      history.goBack();
    } else {
      history.push('/');
    }
  }, [history]);

  return (
    <button
      onClick={handleBackClick}
      className={classNames('column-header__back-button', {
        compact: onlyIcon,
      })}
      aria-label={intl.formatMessage(messages.back)}
    >
      <Icon
        id='chevron-left'
        icon={ArrowBackIcon}
        className='column-back-button__icon'
      />
      {!onlyIcon && (
        <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
      )}
    </button>
  );
};

export interface Props {
  title?: string;
  icon?: string;
  iconComponent?: IconProp;
  active?: boolean;
  children?: React.ReactNode;
  pinned?: boolean;
  multiColumn?: boolean;
  extraButton?: React.ReactNode;
  showBackButton?: boolean;
  placeholder?: boolean;
  appendContent?: React.ReactNode;
  collapseIssues?: boolean;
  onClick?: () => void;
  onMove?: (arg0: number) => void;
  onPin?: () => void;
}

export const ColumnHeader: React.FC<Props> = ({
  title,
  icon,
  iconComponent,
  active,
  children,
  pinned,
  multiColumn,
  extraButton,
  showBackButton,
  placeholder,
  appendContent,
  collapseIssues,
  onClick,
  onMove,
  onPin,
}) => {
  const intl = useIntl();
  const { signedIn } = useIdentity();
  const history = useAppHistory();
  const [collapsed, setCollapsed] = useState(true);
  const [animating, setAnimating] = useState(false);

  const handleToggleClick = useCallback(
    (e: React.MouseEvent) => {
      e.stopPropagation();
      setCollapsed((value) => !value);
      setAnimating(true);
    },
    [setCollapsed, setAnimating],
  );

  const handleTitleClick = useCallback(() => {
    onClick?.();
  }, [onClick]);

  const handleMoveLeft = useCallback(() => {
    onMove?.(-1);
  }, [onMove]);

  const handleMoveRight = useCallback(() => {
    onMove?.(1);
  }, [onMove]);

  const handleTransitionEnd = useCallback(() => {
    setAnimating(false);
  }, [setAnimating]);

  const handlePin = useCallback(() => {
    if (!pinned) {
      history.replace('/');
    }

    onPin?.();
  }, [history, pinned, onPin]);

  const wrapperClassName = classNames('column-header__wrapper', {
    active,
  });

  const buttonClassName = classNames('column-header', {
    active,
  });

  const collapsibleClassName = classNames('column-header__collapsible', {
    collapsed,
    animating,
  });

  const collapsibleButtonClassName = classNames('column-header__button', {
    active: !collapsed,
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
    pinButton = (
      <button
        className='text-btn column-header__setting-btn'
        onClick={handlePin}
      >
        <Icon id='times' icon={CloseIcon} />{' '}
        <FormattedMessage id='column_header.unpin' defaultMessage='Unpin' />
      </button>
    );

    moveButtons = (
      <div className='column-header__setting-arrows'>
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
        className='text-btn column-header__setting-btn'
        onClick={handlePin}
      >
        <Icon id='plus' icon={AddIcon} />{' '}
        <FormattedMessage id='column_header.pin' defaultMessage='Pin' />
      </button>
    );
  }

  if (
    !pinned &&
    ((multiColumn && history.location.state?.fromMastodon) || showBackButton)
  ) {
    backButton = <BackButton onlyIcon={!!title} />;
  }

  const collapsedContent = [extraContent];

  if (multiColumn) {
    collapsedContent.push(
      <div key='buttons' className='column-header__advanced-buttons'>
        {pinButton}
        {moveButtons}
      </div>,
    );
  }

  if (signedIn && (children || (multiColumn && onPin))) {
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
          <Icon id='sliders' icon={SettingsIcon} />
          {collapseIssues && <i className='icon-with-badge__issue-badge' />}
        </i>
      </button>
    );
  }

  const hasIcon = icon && iconComponent;
  const hasTitle = hasIcon && title;

  const component = (
    <div className={wrapperClassName}>
      <h1 className={buttonClassName}>
        {hasTitle && (
          <>
            {backButton}

            <button onClick={handleTitleClick} className='column-header__title'>
              {!backButton && (
                <Icon
                  id={icon}
                  icon={iconComponent}
                  className='column-header__icon'
                />
              )}
              {title}
            </button>
          </>
        )}

        {!hasTitle && backButton}

        <div className='column-header__buttons'>
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

// eslint-disable-next-line import/no-default-export
export default ColumnHeader;
