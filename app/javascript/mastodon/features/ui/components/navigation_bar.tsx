import { useCallback, useEffect } from 'react';

import { useIntl, defineMessages, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { NavLink, useRouteMatch } from 'react-router-dom';

import AddIcon from '@/material-icons/400-24px/add.svg?react';
import HomeActiveIcon from '@/material-icons/400-24px/home-fill.svg?react';
import HomeIcon from '@/material-icons/400-24px/home.svg?react';
import MenuIcon from '@/material-icons/400-24px/menu.svg?react';
import NotificationsActiveIcon from '@/material-icons/400-24px/notifications-fill.svg?react';
import NotificationsIcon from '@/material-icons/400-24px/notifications.svg?react';
import SearchIcon from '@/material-icons/400-24px/search.svg?react';
import { openModal } from 'mastodon/actions/modal';
import { toggleNavigation } from 'mastodon/actions/navigation';
import { fetchServer } from 'mastodon/actions/server';
import { Icon } from 'mastodon/components/icon';
import { IconWithBadge } from 'mastodon/components/icon_with_badge';
import { useIdentity } from 'mastodon/identity_context';
import { registrationsOpen, sso_redirect } from 'mastodon/initial_state';
import { selectUnreadNotificationGroupsCount } from 'mastodon/selectors/notifications';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

export const messages = defineMessages({
  home: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  search: { id: 'tabs_bar.search', defaultMessage: 'Search' },
  publish: { id: 'tabs_bar.publish', defaultMessage: 'New Post' },
  notifications: {
    id: 'tabs_bar.notifications',
    defaultMessage: 'Notifications',
  },
  menu: { id: 'tabs_bar.menu', defaultMessage: 'Menu' },
});

const IconLabelButton: React.FC<{
  to: string;
  icon?: React.ReactNode;
  activeIcon?: React.ReactNode;
  title: string;
}> = ({ to, icon, activeIcon, title }) => {
  const match = useRouteMatch(to);

  return (
    <NavLink
      className='ui__navigation-bar__item'
      activeClassName='active'
      to={to}
      aria-label={title}
    >
      {match && activeIcon ? activeIcon : icon}
    </NavLink>
  );
};

const NotificationsButton = () => {
  const count = useAppSelector(selectUnreadNotificationGroupsCount);
  const intl = useIntl();

  return (
    <IconLabelButton
      to='/notifications'
      icon={
        <IconWithBadge
          id='bell'
          icon={NotificationsIcon}
          count={count}
          className=''
        />
      }
      activeIcon={
        <IconWithBadge
          id='bell'
          icon={NotificationsActiveIcon}
          count={count}
          className=''
        />
      }
      title={intl.formatMessage(messages.notifications)}
    />
  );
};

const LoginOrSignUp: React.FC = () => {
  const dispatch = useAppDispatch();
  const signupUrl = useAppSelector(
    (state) =>
      (state.server.getIn(['server', 'registrations', 'url'], null) as
        | string
        | null) ?? '/auth/sign_up',
  );

  const openClosedRegistrationsModal = useCallback(() => {
    dispatch(openModal({ modalType: 'CLOSED_REGISTRATIONS', modalProps: {} }));
  }, [dispatch]);

  useEffect(() => {
    dispatch(fetchServer());
  }, [dispatch]);

  if (sso_redirect) {
    return (
      <div className='ui__navigation-bar__sign-up'>
        <a
          href={sso_redirect}
          data-method='post'
          className='button button--block button-secondary'
        >
          <FormattedMessage
            id='sign_in_banner.sso_redirect'
            defaultMessage='Login or Register'
          />
        </a>
      </div>
    );
  } else {
    let signupButton;

    if (registrationsOpen) {
      signupButton = (
        <a href={signupUrl} className='button'>
          <FormattedMessage
            id='sign_in_banner.create_account'
            defaultMessage='Create account'
          />
        </a>
      );
    } else {
      signupButton = (
        <button
          className='button'
          onClick={openClosedRegistrationsModal}
          type='button'
        >
          <FormattedMessage
            id='sign_in_banner.create_account'
            defaultMessage='Create account'
          />
        </button>
      );
    }

    return (
      <div className='ui__navigation-bar__sign-up'>
        {signupButton}
        <a href='/auth/sign_in' className='button button-secondary'>
          <FormattedMessage
            id='sign_in_banner.sign_in'
            defaultMessage='Login'
          />
        </a>
      </div>
    );
  }
};

export const NavigationBar: React.FC = () => {
  const { signedIn } = useIdentity();
  const dispatch = useAppDispatch();
  const open = useAppSelector((state) => state.navigation.open);
  const intl = useIntl();

  const handleClick = useCallback(() => {
    dispatch(toggleNavigation());
  }, [dispatch]);

  return (
    <div className='ui__navigation-bar'>
      {!signedIn && <LoginOrSignUp />}

      <div
        className={classNames('ui__navigation-bar__items', {
          active: signedIn,
        })}
      >
        {signedIn && (
          <>
            <IconLabelButton
              title={intl.formatMessage(messages.home)}
              to='/home'
              icon={<Icon id='' icon={HomeIcon} />}
              activeIcon={<Icon id='' icon={HomeActiveIcon} />}
            />
            <IconLabelButton
              title={intl.formatMessage(messages.search)}
              to='/explore'
              icon={<Icon id='' icon={SearchIcon} />}
            />
            <IconLabelButton
              title={intl.formatMessage(messages.publish)}
              to='/publish'
              icon={<Icon id='' icon={AddIcon} />}
            />
            <NotificationsButton />
          </>
        )}

        <button
          className={classNames('ui__navigation-bar__item', { active: open })}
          onClick={handleClick}
          aria-label={intl.formatMessage(messages.menu)}
          type='button'
        >
          <Icon id='' icon={MenuIcon} />
        </button>
      </div>
    </div>
  );
};
