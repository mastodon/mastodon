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
import SettingsIcon from '@/material-icons/400-24px/settings-fill.svg?react';
import { mountCompose, unmountCompose } from 'mastodon/actions/compose';
import { openModal } from 'mastodon/actions/modal';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { Icon } from 'mastodon/components/icon';
import { mascot } from 'mastodon/initial_state';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { Search } from './components/search';
import ComposeFormContainer from './containers/compose_form_container';

const messages = defineMessages({
  start: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  home_timeline: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: {
    id: 'tabs_bar.notifications',
    defaultMessage: 'Notifications',
  },
  public: {
    id: 'navigation_bar.public_timeline',
    defaultMessage: 'Federated timeline',
  },
  community: {
    id: 'navigation_bar.community_timeline',
    defaultMessage: 'Local timeline',
  },
  preferences: {
    id: 'navigation_bar.preferences',
    defaultMessage: 'Preferences',
  },
  logout: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
  compose: { id: 'navigation_bar.compose', defaultMessage: 'Compose new post' },
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

  if (multiColumn) {
    return (
      <div
        className='drawer'
        role='region'
        aria-label={intl.formatMessage(messages.compose)}
      >
        <nav className='drawer__header'>
          <Link
            to='/getting-started'
            className='drawer__tab'
            title={intl.formatMessage(messages.start)}
            aria-label={intl.formatMessage(messages.start)}
          >
            <Icon id='bars' icon={MenuIcon} />
          </Link>
          {!columns.some((column) => column.get('id') === 'HOME') && (
            <Link
              to='/home'
              className='drawer__tab'
              title={intl.formatMessage(messages.home_timeline)}
              aria-label={intl.formatMessage(messages.home_timeline)}
            >
              <Icon id='home' icon={HomeIcon} />
            </Link>
          )}
          {!columns.some((column) => column.get('id') === 'NOTIFICATIONS') && (
            <Link
              to='/notifications'
              className='drawer__tab'
              title={intl.formatMessage(messages.notifications)}
              aria-label={intl.formatMessage(messages.notifications)}
            >
              <Icon id='bell' icon={NotificationsIcon} />
            </Link>
          )}
          {!columns.some((column) => column.get('id') === 'COMMUNITY') && (
            <Link
              to='/public/local'
              className='drawer__tab'
              title={intl.formatMessage(messages.community)}
              aria-label={intl.formatMessage(messages.community)}
            >
              <Icon id='users' icon={PeopleIcon} />
            </Link>
          )}
          {!columns.some((column) => column.get('id') === 'PUBLIC') && (
            <Link
              to='/public'
              className='drawer__tab'
              title={intl.formatMessage(messages.public)}
              aria-label={intl.formatMessage(messages.public)}
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

            <div className='drawer__inner__mastodon'>
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
      label={intl.formatMessage(messages.compose)}
    >
      <ColumnHeader
        icon='pencil'
        iconComponent={EditIcon}
        title={intl.formatMessage(messages.compose)}
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
