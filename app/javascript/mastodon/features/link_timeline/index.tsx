import { useEffect, useCallback } from 'react';

import { useParams } from 'react-router-dom';

import { Helmet } from '@unhead/react/helmet';

import { Column } from '@/mastodon/components/column';
import { ColumnHeader } from '@/mastodon/components/column/header';
import TrendingUpIcon from '@/material-icons/400-24px/trending_up.svg?react';
import { expandLinkTimeline } from 'mastodon/actions/timelines';
import StatusListContainer from 'mastodon/features/ui/containers/status_list_container';
import type { Card } from 'mastodon/models/status';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

export const LinkTimeline: React.FC<{
  multiColumn: boolean;
}> = ({ multiColumn }) => {
  const { url } = useParams<{ url: string }>();
  const decodedUrl = url ? decodeURIComponent(url) : undefined;
  const dispatch = useAppDispatch();
  const firstStatusId = useAppSelector((state) =>
    decodedUrl
      ? (state.timelines.getIn([`link:${decodedUrl}`, 'items', 0]) as string)
      : undefined,
  );
  const story = useAppSelector((state) =>
    firstStatusId
      ? (state.statuses.getIn([firstStatusId, 'card']) as Card)
      : undefined,
  );

  const handleLoadMore = useCallback(
    (maxId: string) => {
      void dispatch(expandLinkTimeline(decodedUrl, { maxId }));
    },
    [dispatch, decodedUrl],
  );

  useEffect(() => {
    void dispatch(expandLinkTimeline(decodedUrl));
  }, [dispatch, decodedUrl]);

  return (
    <Column bindToDocument={!multiColumn} label={story?.title}>
      <ColumnHeader
        icon='explore'
        iconComponent={TrendingUpIcon}
        title={story?.title}
        multiColumn={multiColumn}
        showBackButton
        scrollTopOnClick
      />

      <StatusListContainer
        timelineId={`link:${decodedUrl}`}
        onLoadMore={handleLoadMore}
        trackScroll
        scrollKey={`link_timeline-${decodedUrl}`}
        bindToDocument={!multiColumn}
      />

      <Helmet>
        <title>{story?.title}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default LinkTimeline;
