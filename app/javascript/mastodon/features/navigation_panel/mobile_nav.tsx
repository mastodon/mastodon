import { useCallback, useEffect, useRef } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useLocation } from 'react-router';

import { InfoIcon, MagnifyingGlassIcon } from '@phosphor-icons/react';
import { animated, useSpring } from '@react-spring/web';
import { useDrag } from '@use-gesture/react';

import { Button, IconButton } from '@/mastodon/components/button';
import { Menu, MenuList, MenuTrigger } from '@/mastodon/components/menu';
import { FOCUS_TARGET } from '@/mastodon/components/navigation_focus_target';
import { ComposeButton } from '@/mastodon/features/compose/trigger';
import { useCloseOnHistoryBack } from '@/mastodon/hooks/useCloseOnHistoryBack';
import { useIdentity } from '@/mastodon/identity_context';
import {
  registrationsOpen,
  sso_redirect,
  trendsEnabled,
} from '@/mastodon/initial_state';
import {
  closeMobileMenu,
  openMobileMenu,
} from '@/mastodon/reducers/slices/navigation';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { NavigationPanel, handleSearchLinkClick } from '.';
import { AccountMenuItems } from './account_menu_items';
import { LogoLockup } from './header';
import {
  AccountButton,
  MiniHomeLink,
  MiniMessagesLink,
  MiniNotificationsLink,
} from './mini_nav';
import classes from './mobile_nav.module.scss';
import { MiniNavigationLink } from './navigation_link';

export const MobileNavigation: React.FC = () => {
  const dispatch = useAppDispatch();
  const { signedIn } = useIdentity();

  const openMobileNav = useCallback(() => {
    dispatch(openMobileMenu());
  }, [dispatch]);

  // Hide the mobile sign-up button if registrations are closed or
  // SSO is used (as there's not much room for a detailed label)
  const hasSignUpButton = !sso_redirect && registrationsOpen;

  const signupUrl = useAppSelector(
    (state) => state.server.server.item?.registrations.url ?? '/auth/sign_up',
  );

  return (
    <>
      {signedIn ? (
        <nav className={classes.root}>
          <ul className={classNames(classes.floatingCard, classes.list)}>
            <li>
              <MiniHomeLink />
            </li>
            <li>
              <MiniNavigationLink
                to={{
                  pathname: trendsEnabled ? '/explore' : '/search',
                  state: { focusTarget: FOCUS_TARGET.SEARCH },
                }}
                icon={MagnifyingGlassIcon}
                onClick={handleSearchLinkClick}
              >
                <FormattedMessage
                  id='tabs_bar.search'
                  defaultMessage='Search'
                />
              </MiniNavigationLink>
            </li>
            <li>
              <MiniMessagesLink />
            </li>
            <li>
              <MiniNotificationsLink badgeType='dot' />
            </li>
            <li>
              <Menu>
                <MenuTrigger as={AccountButton}>
                  <FormattedMessage
                    id='tabs_bar.account'
                    defaultMessage='Account'
                  />
                </MenuTrigger>
                <MenuList placement='top-end' offset={8}>
                  <AccountMenuItems context='mobile' />
                </MenuList>
              </Menu>
            </li>
          </ul>
          <ComposeButton inline />
        </nav>
      ) : (
        // Logged out state:
        <nav className={classes.root}>
          <div
            className={classNames(classes.floatingCard, classes.loggedOutInfo)}
          >
            <LogoLockup className={classes.logoLockup} />
            {hasSignUpButton && (
              <Button
                as='a'
                href={signupUrl}
                variant='solid'
                color='accent'
                size='sm'
                className={classes.signUpButton}
              >
                <FormattedMessage
                  id='server_banner.sign_up'
                  defaultMessage='Sign up'
                />
              </Button>
            )}
            <IconButton size='sm' icon={InfoIcon} onClick={openMobileNav}>
              <FormattedMessage id='server_banner.info' defaultMessage='Info' />
            </IconButton>
          </div>
        </nav>
      )}

      <SlideOutNavigation />
    </>
  );
};

const MENU_WIDTH = 320;

const SlideOutNavigation: React.FC = () => {
  const dispatch = useAppDispatch();
  const overlayRef = useRef<HTMLDivElement>(null);

  const isOpen = useAppSelector((state) => state.navigation.isMobileMenuOpen);

  useEffect(() => {
    const handleDocumentClick = (e: MouseEvent) => {
      if (overlayRef.current && e.target === overlayRef.current) {
        dispatch(closeMobileMenu());
      }
    };

    const handleDocumentKeyUp = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        dispatch(closeMobileMenu());
      }
    };

    document.addEventListener('click', handleDocumentClick);
    document.addEventListener('keyup', handleDocumentKeyUp);

    return () => {
      document.removeEventListener('click', handleDocumentClick);
      document.removeEventListener('keyup', handleDocumentKeyUp);
    };
  }, [dispatch]);

  const isLtrDir = getComputedStyle(document.body).direction !== 'rtl';

  const OPEN_MENU_OFFSET = isLtrDir ? -MENU_WIDTH : MENU_WIDTH;

  const [{ x }, spring] = useSpring(
    () => ({
      x: isOpen ? 0 : OPEN_MENU_OFFSET,
      onRest: {
        x({ value }: { value: number }) {
          if (value === 0) {
            dispatch(openMobileMenu());
          } else if (value === OPEN_MENU_OFFSET) {
            dispatch(closeMobileMenu());
          }
        },
      },
    }),
    [isOpen],
  );

  const bind = useDrag(
    ({
      last,
      offset: [xOffset],
      velocity: [xVelocity],
      direction: [xDirection],
      cancel,
    }) => {
      const logicalXDirection = isLtrDir ? -xDirection : xDirection;
      const logicalXOffset = isLtrDir ? -xOffset : xOffset;
      const hasReachedDragThreshold = logicalXOffset < -70;

      if (hasReachedDragThreshold) {
        cancel();
      }

      if (last) {
        const isAboveOpenThreshold = logicalXOffset > MENU_WIDTH / 2;
        const isQuickFlick = xVelocity > 0.5 && logicalXDirection > 0;

        if (isAboveOpenThreshold || isQuickFlick) {
          void spring.start({ x: OPEN_MENU_OFFSET });
        } else {
          void spring.start({ x: 0 });
        }
      } else {
        void spring.start({ x: xOffset, immediate: true });
      }
    },
    {
      from: () => [x.get(), 0],
      axis: 'x',
      filterTaps: true,
      bounds: isLtrDir ? { right: 0 } : { left: 0 },
      rubberband: true,
    },
  );

  const previouslyFocusedElementRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const overlay = overlayRef.current;
    if (isOpen && overlay) {
      const firstLink = overlay.querySelector<HTMLAnchorElement>('a');
      previouslyFocusedElementRef.current =
        document.activeElement as HTMLElement;
      firstLink?.focus();
    } else {
      previouslyFocusedElementRef.current?.focus();
    }
  }, [isOpen]);

  // Close after navigation change
  const { pathname, search } = useLocation();
  const pathWithSearch = `${pathname}${search}`;
  useEffect(() => {
    dispatch(closeMobileMenu());
  }, [pathWithSearch, dispatch]);

  // Close after browser back navigation
  useCloseOnHistoryBack(
    () => {
      dispatch(closeMobileMenu());
    },
    {
      active: isOpen,
    },
  );

  return (
    <div
      className={classes.slideOutWrapper}
      data-is-open={isOpen}
      ref={overlayRef}
      inert={!isOpen}
    >
      <animated.div className={classes.slideOut} {...bind()} style={{ x }}>
        <NavigationPanel mode='slide-out' />
      </animated.div>
    </div>
  );
};
