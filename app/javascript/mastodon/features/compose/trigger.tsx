import { useCallback, useLayoutEffect, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useRouteMatch } from 'react-router';

import { PenNibIcon, ReadCvLogoIcon } from '@phosphor-icons/react';
import { isIPad } from '@react-aria/utils';

import type { IconButtonProps } from '@/mastodon/components/button';
import { IconButton } from '@/mastodon/components/button';
import { useBodyScrollLock } from '@/mastodon/hooks/useBodyScrollLock';
import { useCloseOnHistoryBack } from '@/mastodon/hooks/useCloseOnHistoryBack';
import { useResizeObserver } from '@/mastodon/hooks/useObserver';
import { useViewportSize } from '@/mastodon/hooks/useViewportSize';
import { useIdentity } from '@/mastodon/identity_context';
import {
  closeOrMinimizeComposer,
  minimizeComposerToggle,
  openNewComposer,
} from '@/mastodon/reducers/slices/composer';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { includeMultiColumnPaths } from '@/mastodon/utils/react_router';

import { BREAKPOINTS, useBreakpoint } from '../ui/hooks/useBreakpoint';

import { ComposeFormHeader } from './components/header';
import { ComposeForm } from './form';
import classes from './trigger.module.scss';

const NARROW_HEIGHT = 500;

export const ComposeButton: React.FC<{
  /**
   * Render the button in regular document flow instead of fixed positioning for mobile layout
   */
  inline?: boolean;
}> = ({ inline = false }) => {
  const displayState = useAppSelector((state) => state.composer.displayState);
  const isMobile = useBreakpoint('openable');

  const hasMobileFloatingActionButton = useHasMobileFloatingActionButton({
    isMobile,
  });

  const viewport = useViewportSize();

  const dispatch = useAppDispatch();
  const handleComposerOpen: React.MouseEventHandler<HTMLButtonElement> =
    useCallback(() => {
      dispatch(openNewComposer({ type: 'post' }));
    }, [dispatch]);

  const toggleMinimize = useCallback(() => {
    dispatch(minimizeComposerToggle());
  }, [dispatch]);

  const isMinimized = displayState === 'minimized';

  const handleMinimizedTextClick: React.MouseEventHandler<HTMLDivElement> =
    useCallback(
      (event) => {
        if (
          isMinimized &&
          event.target instanceof HTMLElement &&
          !event.target.closest('button')
        ) {
          dispatch(minimizeComposerToggle());
        }
      },
      [dispatch, isMinimized],
    );

  const { signedIn } = useIdentity();

  const trackComposerHeight = useTrackComposerHeight();

  const isFullscreen =
    viewport.height < NARROW_HEIGHT || viewport.width < BREAKPOINTS.openable;
  const isFullscreenOpen = isFullscreen && displayState === 'showing';

  useBodyScrollLock(displayState === 'showing');

  useCloseOnHistoryBack(
    () => {
      dispatch(closeOrMinimizeComposer());
    },
    {
      active: isFullscreenOpen,
    },
  );

  if (!signedIn) {
    return null;
  }

  const floatingButtonProps = {
    inline,
    hidden: !hasMobileFloatingActionButton,
  } as const;

  // Pass the viewport height as a CSS variable so it's only used for mobile.
  const style = {
    '--viewport-height': `${viewport.height}px`,
  } as React.CSSProperties;

  if (isMobile) {
    if (isMinimized) {
      return (
        <FloatingActionButton
          icon={ReadCvLogoIcon}
          onClick={toggleMinimize}
          {...floatingButtonProps}
          hidden={false} // never hide minimized composer button
          color='neutral'
        >
          <FormattedMessage
            id='compose.expand'
            defaultMessage='Expand composer'
          />
        </FloatingActionButton>
      );
    } else if (displayState === 'hidden') {
      return (
        <FloatingActionButton
          icon={PenNibIcon}
          onClick={handleComposerOpen}
          {...floatingButtonProps}
        >
          <FormattedMessage id='tabs_bar.publish' defaultMessage='New Post' />
        </FloatingActionButton>
      );
    }
  }

  if (displayState === 'hidden') {
    return null;
  }

  return (
    <div
      className={classNames(
        classes.root,
        isMinimized ? classes.minimized : classes.showing,
      )}
      style={style}
      data-fullscreen={isFullscreen}
    >
      {/* eslint-disable jsx-a11y/click-events-have-key-events, jsx-a11y/no-static-element-interactions */}
      <div
        className={classNames(
          isMinimized ? classes.composerMinimized : classes.composer,
        )}
        ref={trackComposerHeight}
        onClick={handleMinimizedTextClick}
      >
        {/* eslint-enable */}
        {!isMinimized ? (
          // Disable autofocus for iPad as it causes scrolling.
          <ComposeForm autoFocus={!isIPad()} className={classes.composeForm} />
        ) : (
          <ComposeFormHeader />
        )}
      </div>
    </div>
  );
};

const FloatingActionButton: React.FC<
  {
    inline: boolean;
    hidden: boolean;
  } & IconButtonProps
> = ({ inline, hidden, ...otherProps }) => {
  return (
    // This component uses a wrapper element to prevent its
    // CSS transitions from messing with the button's own transitions
    <div
      className={classNames(
        classes.buttonWrapper,
        inline && classes.buttonWrapperInline,
        hidden && classes.buttonWrapperHidden,
      )}
      inert={hidden}
    >
      <IconButton variant='solid' color='accent' size='lg' {...otherProps} />
    </div>
  );
};

const MOBILE_COMPOSE_BUTTON_ALLOW_ROUTES = includeMultiColumnPaths([
  '/home',
  '/public',
  '/lists',
  '/tags',
]);
const MOBILE_COMPOSE_BUTTON_BLOCK_ROUTES = includeMultiColumnPaths([
  '/lists/new',
]);

function useHasMobileFloatingActionButton({ isMobile }: { isMobile: boolean }) {
  const isRouteWithMobileComposeButton = !!useRouteMatch({
    path: MOBILE_COMPOSE_BUTTON_ALLOW_ROUTES,
    exact: false,
  });

  const isRouteWithoutMobileComposeButton = !!useRouteMatch({
    path: MOBILE_COMPOSE_BUTTON_BLOCK_ROUTES,
    exact: true,
  });

  const shouldHideMobileComposeButton =
    !isMobile ||
    !isRouteWithMobileComposeButton ||
    isRouteWithoutMobileComposeButton;

  return !shouldHideMobileComposeButton;
}

function useTrackComposerHeight() {
  const [height, setHeight] = useState(0);

  useLayoutEffect(() => {
    document.documentElement.style.setProperty(
      '--current-composer-height',
      height ? `${height}px` : null,
    );
  }, [height]);

  const onResize: ResizeObserverCallback = useCallback((entries) => {
    for (const { target } of entries) {
      if (target instanceof HTMLElement) {
        setHeight(target.offsetHeight);
      }
    }
  }, []);

  const observer = useResizeObserver(onResize);

  const ref = useCallback(
    (node: HTMLDivElement | null) => {
      if (node instanceof HTMLElement) {
        observer.observe(node);
        setHeight(node.offsetHeight);

        return () => {
          observer.unobserve(node);
          setHeight(0);
        };
      }
      return () => undefined;
    },
    [observer],
  );

  return ref;
}
