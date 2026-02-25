import type { PropsWithChildren } from 'react';
import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import HomeIcon from '@/material-icons/400-24px/home-fill.svg?react';
import InsertChartIcon from '@/material-icons/400-24px/insert_chart.svg?react';
import PersonAddIcon from '@/material-icons/400-24px/person_add.svg?react';
import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';
import ReplyAllIcon from '@/material-icons/400-24px/reply_all.svg?react';
import StarIcon from '@/material-icons/400-24px/star.svg?react';
import { setNotificationsFilter } from 'mastodon/actions/notification_groups';
import { Icon } from 'mastodon/components/icon';
import {
  selectSettingsNotificationsQuickFilterActive,
  selectSettingsNotificationsQuickFilterAdvanced,
} from 'mastodon/selectors/settings';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const tooltips = defineMessages({
  mentions: { id: 'notifications.filter.mentions', defaultMessage: 'Mentions' },
  favourites: {
    id: 'notifications.filter.favourites',
    defaultMessage: 'Favorites',
  },
  boosts: { id: 'notifications.filter.boosts', defaultMessage: 'Boosts' },
  polls: { id: 'notifications.filter.polls', defaultMessage: 'Poll results' },
  follows: { id: 'notifications.filter.follows', defaultMessage: 'Follows' },
  statuses: {
    id: 'notifications.filter.statuses',
    defaultMessage: 'Updates from people you follow',
  },
});

const BarButton: React.FC<
  PropsWithChildren<{
    selectedFilter: string;
    type: string;
    title?: string;
  }>
> = ({ selectedFilter, type, title, children }) => {
  const dispatch = useAppDispatch();

  const onClick = useCallback(() => {
    void dispatch(setNotificationsFilter({ filterType: type }));
  }, [dispatch, type]);

  return (
    <button
      className={selectedFilter === type ? 'active' : ''}
      onClick={onClick}
      title={title}
      type='button'
    >
      {children}
    </button>
  );
};

export const FilterBar: React.FC = () => {
  const intl = useIntl();

  const selectedFilter = useAppSelector(
    selectSettingsNotificationsQuickFilterActive,
  );
  const advancedMode = useAppSelector(
    selectSettingsNotificationsQuickFilterAdvanced,
  );

  if (advancedMode)
    return (
      <div className='notification__filter-bar'>
        <BarButton selectedFilter={selectedFilter} type='all' key='all'>
          <FormattedMessage
            id='notifications.filter.all'
            defaultMessage='All'
          />
        </BarButton>
        <BarButton
          selectedFilter={selectedFilter}
          type='mention'
          key='mention'
          title={intl.formatMessage(tooltips.mentions)}
        >
          <Icon id='reply-all' icon={ReplyAllIcon} />
        </BarButton>
        <BarButton
          selectedFilter={selectedFilter}
          type='favourite'
          key='favourite'
          title={intl.formatMessage(tooltips.favourites)}
        >
          <Icon id='star' icon={StarIcon} />
        </BarButton>
        <BarButton
          selectedFilter={selectedFilter}
          type='reblog'
          key='reblog'
          title={intl.formatMessage(tooltips.boosts)}
        >
          <Icon id='retweet' icon={RepeatIcon} />
        </BarButton>
        <BarButton
          selectedFilter={selectedFilter}
          type='poll'
          key='poll'
          title={intl.formatMessage(tooltips.polls)}
        >
          <Icon id='tasks' icon={InsertChartIcon} />
        </BarButton>
        <BarButton
          selectedFilter={selectedFilter}
          type='status'
          key='status'
          title={intl.formatMessage(tooltips.statuses)}
        >
          <Icon id='home' icon={HomeIcon} />
        </BarButton>
        <BarButton
          selectedFilter={selectedFilter}
          type='follow'
          key='follow'
          title={intl.formatMessage(tooltips.follows)}
        >
          <Icon id='user-plus' icon={PersonAddIcon} />
        </BarButton>
      </div>
    );
  else
    return (
      <div className='notification__filter-bar'>
        <BarButton selectedFilter={selectedFilter} type='all' key='all'>
          <FormattedMessage
            id='notifications.filter.all'
            defaultMessage='All'
          />
        </BarButton>
        <BarButton selectedFilter={selectedFilter} type='mention' key='mention'>
          <FormattedMessage
            id='notifications.filter.mentions'
            defaultMessage='Mentions'
          />
        </BarButton>
      </div>
    );
};
