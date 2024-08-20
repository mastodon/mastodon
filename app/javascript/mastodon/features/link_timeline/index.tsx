import { useRef, useEffect, useCallback } from 'react';

import { Helmet } from 'react-helmet';
import { useParams } from 'react-router-dom';

import ExploreIcon from '@/material-icons/400-24px/explore.svg?react';
import { expandLinkTimeline } from 'mastodon/actions/timelines';
import Column from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import StatusListContainer from 'mastodon/features/ui/containers/status_list_container';
import type { Card } from 'mastodon/models/status';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

export const LinkTimeline: React.FC<{
  multiColumn: boolean;
}> = ({ multiColumn }) => {
  const { url } = useParams<{ url: string }>();
  const decodedUrl = url ? decodeURIComponent(url) : undefined;
  const dispatch = useAppDispatch();
  const columnRef = useRef<Column>(null);
  const firstStatusId = useAppSelector((state) =>
    decodedUrl
      ? // eslint-disable-next-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
        (state.timelines.getIn([`link:${decodedUrl}`, 'items', 0]) as string)
      : undefined,
  );
  const story = useAppSelector((state) =>
    firstStatusId
      ? (state.statuses.getIn([firstStatusId, 'card']) as Card)
      : undefined,
  );

  const handleHeaderClick = useCallback(() => {
    columnRef.current?.scrollTop();
  }, []);

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
    <Column bindToDocument={!multiColumn} ref={columnRef} label={story?.title}>
      <ColumnHeader
        icon='explore'
        iconComponent={ExploreIcon}
        title={story?.title}
        onClick={handleHeaderClick}
        multiColumn={multiColumn}
        showBackButton
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
