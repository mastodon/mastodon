import {
  addTransitionType,
  startTransition,
  useCallback,
  useEffect,
  useLayoutEffect,
  useRef,
  useState,
  ViewTransition,
} from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useRouteMatch } from 'react-router';

import { PenNibIcon, ReadCvLogoIcon } from '@phosphor-icons/react';
import { isIPad } from '@react-aria/utils';

import type { IconButtonProps } from '@/mastodon/components/button';
import { IconButton } from '@/mastodon/components/button';
import { useBodyScrollLock } from '@/mastodon/hooks/useBodyScrollLock';
import { useCloseOnHistoryBack } from '@/mastodon/hooks/useCloseOnHistoryBack';
import { useConfirmBeforePageClose } from '@/mastodon/hooks/useConfirmBeforePageClose';
import { useViewportSize } from '@/mastodon/hooks/useViewportSize';
import { useIdentity } from '@/mastodon/identity_context';
import {
  closeOrMinimizeComposer,
  minimizeComposerToggle,
  openNewComposer,
  selectComposerIsChanged,
} from '@/mastodon/reducers/slices/composer';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { includeMultiColumnPaths } from '@/mastodon/utils/react_router';

import { BREAKPOINTS, useBreakpoint } from '../ui/hooks/useBreakpoint';

import { ComposeFormHeader } from './components/header';
import { ComposeForm } from './form';
import classes from './trigger.module.scss';

const NARROW_HEIGHT = 500;

const MINIMIZE: Keyframe[] = [
  { transform: 'translate(0, 0) scale(1)', opacity: 1, offset: 0 },
  { opacity: 1, offset: 0.7 },
  { transform: 'translate(25%, 25%) scale(0.5)', opacity: 0, offset: 1 },
];

const EXPAND: Keyframe[] = [
  { transform: 'translate(0, 0) scale(1)', opacity: 1, offset: 0 },
  { opacity: 1, offset: 0.7 },
  { transform: 'translate(-50%, -50%) scale(2)', opacity: 0, offset: 1 },
];

export const ComposeButton: React.FC<{
  /**
   * Render the button in regular document flow instead of fixed positioning for mobile layout
   */
  inline?: boolean;
}> = ({ inline = false }) => {
  const displayState = useAppSelector((state) => state.composer.displayState);
  const isMobile = useBreakpoint('openable');
  const isComposerChanged = useAppSelector(selectComposerIsChanged);

  const hasMobileFloatingActionButton = useHasMobileFloatingActionButton({
    isMobile,
  });

  const viewport = useViewportSize();

  const dispatch = useAppDispatch();
  const handleComposerOpen: React.MouseEventHandler<HTMLButtonElement> =
    useCallback(() => {
      startTransition(() => {
        dispatch(openNewComposer({ type: 'post' }));
      });
    }, [dispatch]);

  const toggleMinimize = useCallback(() => {
    startTransition(() => {
      dispatch(minimizeComposerToggle());
    });
  }, [dispatch]);

  const isShowing = displayState === 'showing';

  const [isMinimized, setMinimized] = useState(displayState === 'minimized');
  if (displayState === 'hidden' && isMinimized) {
    setMinimized(false);
  }
  useEffect(() => {
    if (isMinimized === isShowing) {
      startTransition(() => {
        addTransitionType(isShowing ? 'composer-expand' : 'composer-minimize');
        setMinimized(!isMinimized);
      });
    }
  }, [displayState, isMinimized, isShowing]);

  const handleViewTransitionUpdate: NonNullable<
    React.ViewTransitionProps['onUpdate']
  > = useCallback(
    (instance) => {
      if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        return;
      }

      const animation = document.documentElement.animate(
        isMinimized ? MINIMIZE : EXPAND,
        {
          duration: 100,
          easing: 'ease-out',
          pseudoElement: `::view-transition-old(${instance.name})`,
        },
      );
      return () => {
        animation.cancel();
      };
    },
    [isMinimized],
  );

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

  useConfirmBeforePageClose(isComposerChanged && displayState !== 'hidden');
  useBodyScrollLock(isShowing);
  useCloseOnHistoryBack(
    () => {
      dispatch(closeOrMinimizeComposer());
    },
    { active: isShowing },
  );
  const rootRef = useRef<HTMLDivElement>(null);
  useLayoutEffect(() => {
    const nodes = rootRef.current?.parentElement?.childNodes;
    if (!nodes) {
      return;
    }

    let inert = false;
    if (isShowing) {
      inert = true;
    }

    for (const node of nodes) {
      if (
        node !== rootRef.current &&
        node instanceof HTMLElement &&
        !node.dataset.noInert
      ) {
        node.inert = inert;
      }
    }

    return () => {
      for (const node of nodes) {
        if (node instanceof HTMLElement) {
          node.inert = false;
        }
      }
    };
  }, [isShowing]);
  const handleOverlayClick = useCallback(() => {
    dispatch(minimizeComposerToggle());
  }, [dispatch]);

  const { signedIn } = useIdentity();
  if (!signedIn) {
    return null;
  }

  if (isMobile) {
    const floatingButtonProps = {
      inline,
      hidden: !hasMobileFloatingActionButton,
    } as const;

    if (isMinimized) {
      return (
        <FloatingActionButton
          icon={ReadCvLogoIcon}
          onClick={toggleMinimize}
          {...floatingButtonProps}
          hidden={false} // never hide minimized composer button
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

  // Pass the viewport height as a CSS variable so it's only used for mobile.
  const style = {
    '--viewport-height': `${viewport.height}px`,
  } as React.CSSProperties;
  const isFullscreen =
    viewport.height < NARROW_HEIGHT || viewport.width < BREAKPOINTS.openable;

  return (
    <>
      {/* eslint-disable jsx-a11y/click-events-have-key-events, jsx-a11y/no-static-element-interactions */}
      <ViewTransition
        name='COMPOSER'
        default='none'
        update={{
          'composer-expand': 'auto',
          'composer-minimize': 'auto',
          default: 'none',
        }}
        onUpdate={handleViewTransitionUpdate}
      >
        <div
          data-fullscreen={isFullscreen}
          style={style}
          ref={rootRef}
          className={classNames(
            isMinimized ? classes.composerMinimized : classes.composer,
          )}
          onClick={handleMinimizedTextClick}
        >
          {!isMinimized ? (
            // Disable autofocus for iPad as it causes scrolling.
            <ComposeForm
              autoFocus={!isIPad()}
              className={classes.composeForm}
            />
          ) : (
            <ComposeFormHeader />
          )}
        </div>
      </ViewTransition>
      <div
        onClick={handleOverlayClick}
        className={classNames(
          classes.modalBackground,
          isFullscreen && classes.isMobile,
          isMinimized && classes.minimized,
        )}
        data-no-inert
      />
      {/* eslint-enable */}
    </>
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
