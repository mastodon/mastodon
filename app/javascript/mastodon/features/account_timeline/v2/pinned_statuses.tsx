import type { FC } from 'react';
import { useCallback, useEffect, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import IconPinned from '@/images/icons/icon_pinned.svg?react';
import {
  expandTimelineByKey,
  timelineKey,
} from '@/mastodon/actions/timelines_typed';
import { Button } from '@/mastodon/components/button';
import { Icon } from '@/mastodon/components/icon';
import { StatusHeader } from '@/mastodon/components/status/header';
import type { StatusHeaderRenderFn } from '@/mastodon/components/status/header';
import { StatusQuoteManager } from '@/mastodon/components/status_quoted';
import { selectTimelineByKey } from '@/mastodon/selectors/timelines';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { PinnedBadge } from '../components/badges';

import classes from './styles.module.scss';

export const PinnedStatuses: FC<{ accountId: string; tagged?: string }> = ({
  accountId,
  tagged,
}) => {
  // Load pinned statuses
  const dispatch = useAppDispatch();
  const key = timelineKey({
    type: 'account',
    userId: accountId,
    tagged,
    pinned: true,
  });
  useEffect(() => {
    if (accountId) {
      dispatch(expandTimelineByKey({ key }));
    }
  }, [accountId, dispatch, key, tagged]);
  const pinnedTimeline = useAppSelector((state) =>
    selectTimelineByKey(state, key),
  );

  const [showOverflow, setShowOverflow] = useState(false);
  const handleShowOverflow = useCallback(() => {
    setShowOverflow(true);
  }, []);

  if (!pinnedTimeline || pinnedTimeline.isLoading) {
    return null;
  }

  const statuses = showOverflow
    ? pinnedTimeline.items
    : pinnedTimeline.items.slice(0, 1);

  return (
    <div
      className={classNames(
        classes.pinnedWrapper,
        !showOverflow && classes.pinnedWrapperCollapsed,
      )}
    >
      {statuses.map((id) => (
        <StatusQuoteManager
          key={id}
          id={id}
          featured
          contextType='account'
          showThread
          headerRenderFn={renderHeader}
        />
      ))}
      {!showOverflow && pinnedTimeline.items.size > 1 && (
        <Button
          onClick={handleShowOverflow}
          className={classes.pinnedViewAllButton}
        >
          <Icon id='pinned' icon={IconPinned} />
          <FormattedMessage
            id='account.timeline.pinned.view_all'
            defaultMessage='View all pinned posts'
          />
        </Button>
      )}
    </div>
  );
};

const renderHeader: StatusHeaderRenderFn = (args) => (
  <StatusHeader {...args} className={classes.pinnedStatusHeader}>
    <PinnedBadge />
  </StatusHeader>
);
