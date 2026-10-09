import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useLocation } from 'react-router';

import { ArrowLeftIcon, ArrowUpIcon, ListIcon } from '@phosphor-icons/react';
import type { DistributedOmit } from 'type-fest';

import { openNavigation } from '@/mastodon/actions/navigation';
import { getColumnSkipLinkId } from '@/mastodon/features/ui/components/skip_links';
import { useBreakpoint } from '@/mastodon/features/ui/hooks/useBreakpoint';
import { useResizeObserver } from '@/mastodon/hooks/useObserver';
import { useAppDispatch } from '@/mastodon/store';
import { hasReactChildren } from '@/mastodon/utils/has_react_children';

import type { IconButtonProps } from '../button/redesign';
import { Button, IconButton } from '../button/redesign';
import { useColumn, useColumnIndexContext } from '../column/context';
import { NavigationFocusTarget } from '../navigation_focus_target';
import type { LocationState } from '../router';
import { useAppHistory } from '../router';

import classes from './styles.module.scss';

export { ColumnSettingsMenu } from './column_settings_menu';

export interface ColumnHeaderProps {
  title: React.ReactNode;
  // Set to auto to display the back button based on
  // the `fromMastodon` location state
  withBackButton?: boolean | 'auto';
  withUnreadMarker?: boolean;
  extraButtons?: React.ReactNode;
  extraStickyContent?: React.ReactNode;
  className?: string;
}

export const ColumnHeader: React.FC<ColumnHeaderProps> = ({
  title,
  withBackButton,
  withUnreadMarker,
  extraButtons,
  extraStickyContent,
  className,
  ...props
}: ColumnHeaderProps) => {
  const columnIndex = useColumnIndexContext();
  const location = useLocation<LocationState>();
  const hasBackButton =
    withBackButton === true ||
    (withBackButton === 'auto' && location.state?.fromMastodon);
  const hasExtraStickyContent = hasReactChildren(extraStickyContent);

  const { isScrolledToTop, scrollTop } = useColumn();

  const handleHeaderClick = useCallback<React.MouseEventHandler>(
    (e) => {
      // Only scroll to top when clicking outside
      // of the leftButton/rightButtons containers
      if (
        e.target instanceof Element &&
        !e.target.matches(`
          .${classes.leftButton},
          .${classes.leftButton} *,
          .${classes.rightButtons},
          .${classes.rightButtons} *`)
      ) {
        scrollTop();
      }
    },
    [scrollTop],
  );

  const hasScrollToTopButton = !isScrolledToTop && withUnreadMarker;
  const headerRef = useTrackColumnHeaderHeight();

  return (
    <header
      {...props}
      ref={headerRef}
      className={classNames(
        className,
        classes.root,
        hasExtraStickyContent && classes.withStickyContent,
      )}
    >
      {/* eslint-disable-next-line
          jsx-a11y/no-static-element-interactions, jsx-a11y/click-events-have-key-events
        */}
      <div className={classes.layout} onClick={handleHeaderClick}>
        {hasBackButton ? <BackButton /> : <MobileMenuButton />}
        <NavigationFocusTarget className={classes.title}>
          <button
            type='button'
            onClick={scrollTop}
            id={getColumnSkipLinkId(columnIndex)}
          >
            {title}
          </button>
        </NavigationFocusTarget>
        {hasReactChildren(extraButtons) && (
          <div className={classes.rightButtons}>{extraButtons}</div>
        )}
      </div>
      {hasExtraStickyContent && (
        <div className={classes.extraStickyContent}>{extraStickyContent}</div>
      )}
      {hasScrollToTopButton && (
        <Button
          size='sm'
          color='accent'
          variant='solid'
          onClick={scrollTop}
          leadingIcon={ArrowUpIcon}
          className={classes.unreadButton}
        >
          <FormattedMessage
            id='column_header.scroll_to_top'
            defaultMessage='Scroll to top'
          />
        </Button>
      )}
    </header>
  );
};

type ColumnHeaderButtonProps = DistributedOmit<IconButtonProps, 'size'> & {
  showTextOnDesktop?: boolean;
};

export const ColumnHeaderButton: React.FC<ColumnHeaderButtonProps> = ({
  showTextOnDesktop,
  variant = 'ghost',
  icon,
  children,
  ...props
}) => {
  const isMobile = useBreakpoint('openable');

  if (showTextOnDesktop && !isMobile) {
    return (
      <Button {...props} variant={variant} size='sm'>
        {children}
      </Button>
    );
  }

  return (
    <IconButton icon={icon} {...props} variant={variant} size='sm'>
      {children}
    </IconButton>
  );
};

const BackButton: React.FC = () => {
  const history = useAppHistory();

  const goBack = useCallback(() => {
    if (history.location.state?.fromMastodon) {
      history.goBack();
    } else {
      history.push('/');
    }
  }, [history]);

  return (
    <div className={classes.leftButton}>
      <ColumnHeaderButton onClick={goBack} icon={ArrowLeftIcon}>
        <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
      </ColumnHeaderButton>
    </div>
  );
};

const MobileMenuButton: React.FC = () => {
  const dispatch = useAppDispatch();

  const openMobileNavigation = useCallback(() => {
    dispatch(openNavigation());
  }, [dispatch]);

  const isMobile = useBreakpoint('openable');

  if (!isMobile) {
    return null;
  }

  return (
    <div className={classes.leftButton}>
      <ColumnHeaderButton onClick={openMobileNavigation} icon={ListIcon}>
        <FormattedMessage id='tabs_bar.menu' defaultMessage='Menu' />
      </ColumnHeaderButton>
    </div>
  );
};

function updateHeaderHeightCssVariable(element: HTMLElement) {
  const newHeight = `${element.offsetHeight}px`;
  const currentHeight = getComputedStyle(
    document.documentElement,
  ).getPropertyValue('--column-header-height');

  if (newHeight !== currentHeight) {
    document.documentElement.style.setProperty(
      '--column-header-height',
      `${element.offsetHeight}px`,
    );
  }
}

/**
 * Writes changes in the column header's height to a CSS variable
 * that is used to keep feed items in view when navigating them via hotkeys
 */
function useTrackColumnHeaderHeight() {
  const onResize: ResizeObserverCallback = useCallback((entries) => {
    for (const { target } of entries) {
      if (target instanceof HTMLElement) {
        updateHeaderHeightCssVariable(target);
      }
    }
  }, []);

  const observer = useResizeObserver(onResize);

  const headerRef = useCallback(
    (node: HTMLDivElement | null) => {
      const isMultiColumnLayout = !!document.querySelector(
        'body.layout-multiple-columns',
      );
      if (!node || isMultiColumnLayout) {
        return;
      }

      observer.observe(node);
      updateHeaderHeightCssVariable(node);

      return () => {
        observer.unobserve(node);
      };
    },
    [observer],
  );

  return headerRef;
}
