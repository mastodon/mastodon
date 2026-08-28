import { useCallback, useEffect, useRef } from 'react';

import { FormattedMessage } from 'react-intl';

import { useLocation } from 'react-router';

import {
  BellIcon,
  ChatCircleIcon,
  HouseIcon,
  MagnifyingGlassIcon,
  HamburgerIcon,
} from '@phosphor-icons/react';
import { animated, useSpring } from '@react-spring/web';
import { useDrag } from '@use-gesture/react';

import { closeNavigation, openNavigation } from '@/mastodon/actions/navigation';
import { Avatar } from '@/mastodon/components/avatar';
import { IconButton } from '@/mastodon/components/button/redesign';
import { FOCUS_TARGET } from '@/mastodon/components/navigation_focus_target';
import { ComposeRedesignButton } from '@/mastodon/features/compose/redesign/trigger';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useIdentity } from '@/mastodon/identity_context';
import { selectUnreadNotificationGroupsCount } from '@/mastodon/selectors/notifications';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { RedesignNavigationPanel } from '.';
import classes from './mobile_nav.module.scss';
import { MobileNavLink } from './navigation_link';

export const RedesignMobileNavigation: React.FC = () => {
  const { accountId } = useIdentity();
  const account = useAccount(accountId);
  const notificationsCount = useAppSelector(
    selectUnreadNotificationGroupsCount,
  );
  const dispatch = useAppDispatch();
  const handleMenuClick = useCallback(() => {
    dispatch(openNavigation());
  }, [dispatch]);
  return (
    <>
      <nav className={classes.root}>
        <ul className={classes.list}>
          <MobileNavLink to='/home' iconComponent={HouseIcon}>
            <FormattedMessage id='tabs_bar.home' defaultMessage='Home' />
          </MobileNavLink>
          <MobileNavLink
            to={{
              pathname: '/explore',
              state: { focusTarget: FOCUS_TARGET.SEARCH },
            }}
            iconComponent={MagnifyingGlassIcon}
          >
            <FormattedMessage id='tabs_bar.search' defaultMessage='Search' />
          </MobileNavLink>
          <MobileNavLink to='/conversations' iconComponent={ChatCircleIcon}>
            <FormattedMessage
              id='tabs_bar.messages'
              defaultMessage='Messages'
              description='Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.'
            />
          </MobileNavLink>
          <MobileNavLink
            to='/notifications'
            iconComponent={BellIcon}
            withDot={notificationsCount > 0}
          >
            <FormattedMessage
              id='tabs_bar.notifications'
              defaultMessage='Notifications'
            />
          </MobileNavLink>
          <MobileNavLink
            to={`/@${account?.acct}`}
            customIcon={
              <Avatar size={24} account={account} className={classes.avatar} />
            }
          >
            <FormattedMessage id='tabs_bar.profile' defaultMessage='Profile' />
          </MobileNavLink>
        </ul>
        <ComposeRedesignButton inline />
        <IconButton
          icon={HamburgerIcon}
          variant='solid'
          onClick={handleMenuClick}
        >
          Menu
        </IconButton>
      </nav>
      <SlideOutNavigation />
    </>
  );
};

const MENU_WIDTH = 320;

const SlideOutNavigation: React.FC = () => {
  const dispatch = useAppDispatch();
  const location = useLocation();
  const overlayRef = useRef<HTMLDivElement>(null);

  const isOpen = useAppSelector((state) => state.navigation.open);

  useEffect(() => {
    dispatch(closeNavigation());
  }, [dispatch, location]);

  useEffect(() => {
    const handleDocumentClick = (e: MouseEvent) => {
      if (overlayRef.current && e.target === overlayRef.current) {
        dispatch(closeNavigation());
      }
    };

    const handleDocumentKeyUp = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        dispatch(closeNavigation());
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

  const OPEN_MENU_OFFSET = isLtrDir ? MENU_WIDTH : -MENU_WIDTH;

  const [{ x }, spring] = useSpring(
    () => ({
      x: isOpen ? 0 : OPEN_MENU_OFFSET,
      onRest: {
        x({ value }: { value: number }) {
          if (value === 0) {
            dispatch(openNavigation());
          } else if (value === OPEN_MENU_OFFSET) {
            dispatch(closeNavigation());
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
      const logicalXDirection = isLtrDir ? xDirection : -xDirection;
      const logicalXOffset = isLtrDir ? xOffset : -xOffset;
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
      bounds: isLtrDir ? { left: 0 } : { right: 0 },
      rubberband: true,
    },
  );

  const previouslyFocusedElementRef = useRef<HTMLElement>(null);

  useEffect(() => {
    if (isOpen) {
      const firstLink = document.querySelector<HTMLAnchorElement>(
        '.navigation-panel__menu .column-link',
      );
      previouslyFocusedElementRef.current =
        document.activeElement as HTMLElement;
      firstLink?.focus();
    } else {
      previouslyFocusedElementRef.current?.focus();
    }
  }, [isOpen]);

  return (
    <div
      className={classes.slideOutWrapper}
      data-is-open={isOpen}
      ref={overlayRef}
    >
      <animated.div className={classes.slideOut} {...bind()} style={{ x }}>
        <RedesignNavigationPanel />
      </animated.div>
    </div>
  );
};
