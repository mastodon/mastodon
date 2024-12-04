import { useCallback, useEffect } from 'react';

import { useParams } from 'react-router-dom';

import { expandListTimeline } from 'mastodon/actions/timelines';
import StatusList from 'mastodon/features/ui/containers/status_list_container';
import { useAppDispatch } from 'mastodon/store';

export const Statuses: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const { id }: { id: string } = useParams();
  const dispatch = useAppDispatch();

  const handleLoadMore = useCallback(
    (maxId: string) => {
      void dispatch(expandListTimeline(id, { maxId }));
    },
    [dispatch, id],
  );

  useEffect(() => {
    void dispatch(expandListTimeline(id));
  }, [dispatch, id]);

  return (
    <StatusList
      scrollKey={`public_list/${id}/statuses`}
      trackScroll={!multiColumn}
      bindToDocument={!multiColumn}
      timelineId={`list:${id}`}
      onLoadMore={handleLoadMore}
    />
  );
};
