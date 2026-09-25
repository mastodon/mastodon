/* eslint-disable jsx-a11y/no-autofocus */
import { lazy, Suspense, useCallback, useEffect, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useRouteMatch } from 'react-router';

import {
  ChatCircleDotsIcon,
  NewspaperIcon,
  PenNibIcon,
  ReadCvLogoIcon,
} from '@phosphor-icons/react';

import type { IconButtonProps } from '@/mastodon/components/button/redesign';
import { IconButton } from '@/mastodon/components/button/redesign';
import {
  Menu,
  MenuTrigger,
  MenuList,
  MenuItem,
} from '@/mastodon/components/menu';
import { MenuCard } from '@/mastodon/components/menu/card';
import { useIdentity } from '@/mastodon/identity_context';
import {
  minimizeComposerToggle,
  openNewComposer,
} from '@/mastodon/reducers/slices/composer';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { isRedesignEnabled } from '@/mastodon/utils/environment';

import { useBreakpoint } from '../../ui/hooks/useBreakpoint';

import { ComposeFormHeader } from './header';
import classes from './trigger.module.scss';

const ComposeLazyForm = lazy(() =>
  import('./index').then(({ RedesignComposeForm }) => ({
    default: RedesignComposeForm,
  })),
);

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
    useCallback(
      (event) => {
        const {
          currentTarget: { name },
        } = event;
        if (name === 'post' || name === 'message') {
          dispatch(openNewComposer({ type: name }));
        }
      },
      [dispatch],
    );

  const toggleMinimize = useCallback(() => {
    dispatch(minimizeComposerToggle());
  }, [dispatch]);

  const { signedIn } = useIdentity();

  if (!isRedesignEnabled() || !signedIn) {
    return null;
  }

  const floatingButtonProps = {
    inline,
    hidden: !hasMobileFloatingActionButton,
  } as const;

  if (displayState === 'minimized') {
    return isMobile ? (
      <FloatingActionButton
        icon={ReadCvLogoIcon}
        onClick={toggleMinimize}
        {...floatingButtonProps}
        hidden={false} // never hide minimized composer button
      >
        <FormattedMessage id='compose.expand' defaultMessage='Show composer' />
      </FloatingActionButton>
    ) : (
      <MenuCard className={classes.composerMinimized} elevation={2}>
        <ComposeFormHeader />
      </MenuCard>
    );
  }

  if (displayState === 'showing') {
    // Pass the viewport height as a CSS variable so it's only used for mobile.
    const style = {
      '--viewport-height': viewportHeight ? `${viewportHeight}px` : undefined,
    } as React.CSSProperties;
    return (
      <Suspense
        fallback={
          <FloatingActionButton
            loading
            icon={PenNibIcon}
            {...floatingButtonProps}
          >
            <FormattedMessage
              id='compose.new'
              defaultMessage='Write a new post or messsage'
            />
          </FloatingActionButton>
        }
      >
        <ComposeLazyForm autoFocus className={classes.composer} style={style} />
      </Suspense>
    );
  }

  return (
    <Menu>
      <MenuTrigger
        as={FloatingActionButton}
        icon={PenNibIcon}
        {...floatingButtonProps}
      >
        <FormattedMessage
          id='compose.new'
          defaultMessage='Write a new post or messsage'
        />
      </MenuTrigger>

      <MenuList maxWidth={180} placement='top-end'>
        <MenuItem name='post' onClick={handleComposerOpen} icon={NewspaperIcon}>
          <FormattedMessage id='compose.new.post' defaultMessage='Post' />
        </MenuItem>

        <MenuItem
          name='message'
          onClick={handleComposerOpen}
          icon={ChatCircleDotsIcon}
        >
          <FormattedMessage
            id='compose.new.message'
            defaultMessage='Message'
            description='Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.'
          />
        </MenuItem>
      </MenuList>
    </Menu>
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
      <IconButton variant='solid' size='lg' {...otherProps} />
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
    isMobile &&
    (!isRouteWithMobileComposeButton || isRouteWithoutMobileComposeButton);

  return !shouldHideMobileComposeButton;
}
