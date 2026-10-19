import { useCallback, useEffect, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useRouteMatch } from 'react-router';

import { PenNibIcon, ReadCvLogoIcon } from '@phosphor-icons/react';

import type { IconButtonProps } from '@/flavours/glitch/components/button/redesign';
import { IconButton } from '@/flavours/glitch/components/button/redesign';
import { useIdentity } from '@/flavours/glitch/identity_context';
import {
  minimizeComposerToggle,
  openNewComposer,
} from '@/flavours/glitch/reducers/slices/composer';
import { useAppDispatch, useAppSelector } from '@/flavours/glitch/store';
import { isRedesignEnabled } from '@/flavours/glitch/utils/environment';

import { useBreakpoint } from '../../ui/hooks/useBreakpoint';

import { ComposeFormHeader } from './header';
import { RedesignComposeForm } from './index';
import composerClasses from './styles.module.scss';
import classes from './trigger.module.scss';

export const ComposeRedesignButton: React.FC<{
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

  // Update viewport based on visual size in order to account for the virtual keyboard.
  const [viewportHeight, setViewportHeight] = useState<null | number>(null);
  useEffect(() => {
    const updateHeight = () => {
      setViewportHeight(visualViewport?.height ?? null);
    };

    visualViewport?.addEventListener('resize', updateHeight);

    return () => {
      visualViewport?.removeEventListener('resize', updateHeight);
    };
  }, []);

  const dispatch = useAppDispatch();
  const handleComposerOpen: React.MouseEventHandler<HTMLButtonElement> =
    useCallback(() => {
      dispatch(openNewComposer({ type: 'post' }));
    }, [dispatch]);

  const toggleMinimize = useCallback(() => {
    dispatch(minimizeComposerToggle());
  }, [dispatch]);

  const handleMinimizedTextClick: React.MouseEventHandler<HTMLDivElement> =
    useCallback(
      (event) => {
        if (
          event.target instanceof HTMLElement &&
          !event.target.closest('button')
        ) {
          dispatch(minimizeComposerToggle());
        }
      },
      [dispatch],
    );

  const { signedIn } = useIdentity();

  if (!isRedesignEnabled() || !signedIn) {
    return null;
  }

  const floatingButtonProps = {
    inline,
    hidden: !hasMobileFloatingActionButton,
  } as const;

  // Pass the viewport height as a CSS variable so it's only used for mobile.
  const style = {
    '--viewport-height': viewportHeight ? `${viewportHeight}px` : undefined,
  } as React.CSSProperties;

  if (displayState === 'minimized') {
    return isMobile ? (
      <FloatingActionButton
        icon={ReadCvLogoIcon}
        onClick={toggleMinimize}
        {...floatingButtonProps}
        hidden={false} // never hide minimized composer button
        color='neutral'
      >
        <FormattedMessage id='compose.expand' defaultMessage='Show composer' />
      </FloatingActionButton>
    ) : (
      <div className={classes.root} style={style}>
        {/* eslint-disable jsx-a11y/click-events-have-key-events, jsx-a11y/no-static-element-interactions */}
        <div
          onClick={handleMinimizedTextClick}
          className={classNames(
            classes.composerMinimized,
            composerClasses.root,
          )}
        >
          <ComposeFormHeader />
        </div>
        {/* eslint-enable */}
      </div>
    );
  }

  if (displayState === 'showing') {
    return (
      <div className={classes.root} style={style}>
        <RedesignComposeForm autoFocus className={classes.composer} />
      </div>
    );
  }

  return (
    <FloatingActionButton
      icon={PenNibIcon}
      onClick={handleComposerOpen}
      {...floatingButtonProps}
    >
      <FormattedMessage id='tabs_bar.publish' defaultMessage='New Post' />
    </FloatingActionButton>
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

function includeMultiColumnPaths(paths: string[]) {
  return [...paths, ...paths.map((path) => `/deck${path}`)];
}

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
