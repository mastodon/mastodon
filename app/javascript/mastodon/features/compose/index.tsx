import { useEffect, useCallback } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import { Helmet } from 'react-helmet';
import { Link } from 'react-router-dom';

import type { Map as ImmutableMap, List as ImmutableList } from 'immutable';

import elephantUIPlane from '@/images/elephant_ui_plane.svg';
import EditIcon from '@/material-icons/400-24px/edit_square.svg?react';
import PeopleIcon from '@/material-icons/400-24px/group.svg?react';
import HomeIcon from '@/material-icons/400-24px/home-fill.svg?react';
import LogoutIcon from '@/material-icons/400-24px/logout.svg?react';
import MenuIcon from '@/material-icons/400-24px/menu.svg?react';
import NotificationsIcon from '@/material-icons/400-24px/notifications-fill.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import SettingsIcon from '@/material-icons/400-24px/settings.svg?react';
import { mountCompose, unmountCompose } from 'mastodon/actions/compose';
import { openModal } from 'mastodon/actions/modal';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { Icon } from 'mastodon/components/icon';
import { mascot, reduceMotion } from 'mastodon/initial_state';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { messages as navbarMessages } from '../ui/components/navigation_bar';

import { Search } from './components/search';
import ComposeFormContainer from './containers/compose_form_container';

const messages = defineMessages({
  live_feed_public: {
    id: 'navigation_bar.live_feed_public',
    defaultMessage: 'Live feed (public)',
  },
  live_feed_local: {
    id: 'navigation_bar.live_feed_local',
    defaultMessage: 'Live feed (local)',
  },
  preferences: {
    id: 'navigation_bar.preferences',
    defaultMessage: 'Preferences',
  },
  logout: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
});

type ColumnMap = ImmutableMap<'id' | 'uuid' | 'params', string>;

const Compose: React.FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const columns = useAppSelector(
    (state) =>
      (state.settings as ImmutableMap<string, unknown>).get(
        'columns',
      ) as ImmutableList<ColumnMap>,
  );

  useEffect(() => {
    dispatch(mountCompose());

    return () => {
      dispatch(unmountCompose());
    };
  }, [dispatch]);

  const handleLogoutClick = useCallback(
    (e: React.MouseEvent) => {
      e.preventDefault();
      e.stopPropagation();

      dispatch(openModal({ modalType: 'CONFIRM_LOG_OUT', modalProps: {} }));

      return false;
    },
    [dispatch],
  );

  const scrollNavbarIntoView = useCallback(() => {
    const navbar = document.querySelector('.navigation-panel');
    navbar?.scrollIntoView({
      behavior: reduceMotion ? 'auto' : 'smooth',
    });
  }, []);

  if (multiColumn) {
    return (
      <div
        className='drawer'
        role='region'
        aria-label={intl.formatMessage(navbarMessages.publish)}
      >
        <nav className='drawer__header'>
          <Link
            to='/getting-started'
            className='drawer__tab'
            title={intl.formatMessage(navbarMessages.menu)}
            aria-label={intl.formatMessage(navbarMessages.menu)}
            onClick={scrollNavbarIntoView}
          >
            <Icon id='bars' icon={MenuIcon} />
          </Link>
          {!columns.some((column) => column.get('id') === 'HOME') && (
            <Link
              to='/home'
              className='drawer__tab'
              title={intl.formatMessage(navbarMessages.home)}
              aria-label={intl.formatMessage(navbarMessages.home)}
            >
              <Icon id='home' icon={HomeIcon} />
            </Link>
          )}
          {!columns.some((column) => column.get('id') === 'NOTIFICATIONS') && (
            <Link
              to='/notifications'
              className='drawer__tab'
              title={intl.formatMessage(navbarMessages.notifications)}
              aria-label={intl.formatMessage(navbarMessages.notifications)}
            >
              <Icon id='bell' icon={NotificationsIcon} />
            </Link>
          )}
          {!columns.some((column) => column.get('id') === 'COMMUNITY') && (
            <Link
              to='/public/local'
              className='drawer__tab'
              title={intl.formatMessage(messages.live_feed_local)}
              aria-label={intl.formatMessage(messages.live_feed_local)}
            >
              <Icon id='users' icon={PeopleIcon} />
            </Link>
          )}
          {!columns.some((column) => column.get('id') === 'PUBLIC') && (
            <Link
              to='/public'
              className='drawer__tab'
              title={intl.formatMessage(messages.live_feed_public)}
              aria-label={intl.formatMessage(messages.live_feed_public)}
            >
              <Icon id='globe' icon={PublicIcon} />
            </Link>
          )}
          <a
            href='/settings/preferences'
            className='drawer__tab'
            title={intl.formatMessage(messages.preferences)}
            aria-label={intl.formatMessage(messages.preferences)}
          >
            <Icon id='cog' icon={SettingsIcon} />
          </a>
          <a
            href='/auth/sign_out'
            className='drawer__tab'
            title={intl.formatMessage(messages.logout)}
            aria-label={intl.formatMessage(messages.logout)}
            onClick={handleLogoutClick}
          >
            <Icon id='sign-out' icon={LogoutIcon} />
          </a>
        </nav>

        <Search singleColumn={false} />

        <div className='drawer__pager'>
          <div className='drawer__inner'>
            <ComposeFormContainer />

            <div className='drawer__inner__mastodon with-zig-zag-decoration'>
              <img alt='' draggable='false' src={mascot ?? elephantUIPlane} />
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <Column
      bindToDocument={!multiColumn}
      label={intl.formatMessage(navbarMessages.publish)}
    >
      <ColumnHeader
        icon='pencil'
        iconComponent={EditIcon}
        title={intl.formatMessage(navbarMessages.publish)}
        multiColumn={multiColumn}
        showBackButton
      />

      <div className='scrollable'>
        <ComposeFormContainer />
      </div>

      <Helmet>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default Compose;
