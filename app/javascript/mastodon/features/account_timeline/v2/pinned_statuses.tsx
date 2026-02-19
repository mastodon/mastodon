import type { FC } from 'react';
import { useEffect, useMemo } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import IconPinned from '@/images/icons/icon_pinned.svg?react';
import { TIMELINE_PINNED_VIEW_ALL } from '@/mastodon/actions/timelines';
import {
  expandTimelineByKey,
  timelineKey,
} from '@/mastodon/actions/timelines_typed';
import { Button } from '@/mastodon/components/button';
import { Icon } from '@/mastodon/components/icon';
import { StatusHeader } from '@/mastodon/components/status/header';
import type { StatusHeaderRenderFn } from '@/mastodon/components/status/header';
import { selectTimelineByKey } from '@/mastodon/selectors/timelines';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { isRedesignEnabled } from '../common';
import { PinnedBadge } from '../components/badges';

import { useAccountContext } from './context';
import classes from './styles.module.scss';

export function usePinnedStatusIds({
  accountId,
  tagged,
  forceEmptyState = false,
}: {
  accountId: string;
  tagged?: string;
  forceEmptyState?: boolean;
}) {
  const pinnedKey = timelineKey({
    type: 'account',
    userId: accountId,
    tagged,
    pinned: true,
  });

  const dispatch = useAppDispatch();
  useEffect(() => {
    dispatch(expandTimelineByKey({ key: pinnedKey }));
  }, [dispatch, pinnedKey]);

  const pinnedTimeline = useAppSelector((state) =>
    selectTimelineByKey(state, pinnedKey),
  );

  const { showAllPinned } = useAccountContext();

  const pinnedTimelineItems = pinnedTimeline?.items; // Make a const to avoid the React Compiler complaining.
  const pinnedStatusIds = useMemo(() => {
    if (!pinnedTimelineItems || forceEmptyState) {
      return undefined;
    }

    if (pinnedTimelineItems.size <= 1 || showAllPinned) {
      return pinnedTimelineItems;
    }
    return pinnedTimelineItems.slice(0, 1).push(TIMELINE_PINNED_VIEW_ALL);
  }, [forceEmptyState, pinnedTimelineItems, showAllPinned]);

  return {
    statusIds: pinnedStatusIds,
    isLoading: !!pinnedTimeline?.isLoading,
    showAllPinned,
  };
}

export const renderPinnedStatusHeader: StatusHeaderRenderFn = ({
  featured,
  ...args
}) => {
  if (!featured) {
    return <StatusHeader {...args} />;
  }
  return (
    <StatusHeader {...args} className={classes.pinnedStatusHeader}>
      <PinnedBadge />
    </StatusHeader>
  );
};

export const PinnedShowAllButton: FC = () => {
  const { onShowAllPinned } = useAccountContext();

  if (!isRedesignEnabled()) {
    return null;
  }

  return (
    <Button
      onClick={onShowAllPinned}
      className={classNames(classes.pinnedViewAllButton, 'focusable')}
    >
      <Icon id='pinned' icon={IconPinned} />
      <FormattedMessage
        id='account.timeline.pinned.view_all'
        defaultMessage='View all pinned posts'
      />
    </Button>
  );
};
