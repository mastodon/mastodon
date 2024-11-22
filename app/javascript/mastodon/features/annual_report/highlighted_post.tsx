/* eslint-disable @typescript-eslint/no-unsafe-return,
                  @typescript-eslint/no-explicit-any,
                  @typescript-eslint/no-unsafe-assignment */

import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { toggleStatusSpoilers } from 'mastodon/actions/statuses';
import { DetailedStatus } from 'mastodon/features/status/components/detailed_status';
import { me } from 'mastodon/initial_state';
import type { TopStatuses } from 'mastodon/models/annual_report';
import { makeGetStatus, makeGetPictureInPicture } from 'mastodon/selectors';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

const getStatus = makeGetStatus() as unknown as (arg0: any, arg1: any) => any;
const getPictureInPicture = makeGetPictureInPicture() as unknown as (
  arg0: any,
  arg1: any,
) => any;

export const HighlightedPost: React.FC<{
  data: TopStatuses;
}> = ({ data }) => {
  let statusId, label;

  if (data.by_reblogs) {
    statusId = data.by_reblogs;
    label = (
      <FormattedMessage
        id='annual_report.summary.highlighted_post.by_reblogs'
        defaultMessage='most boosted post'
      />
    );
  } else if (data.by_favourites) {
    statusId = data.by_favourites;
    label = (
      <FormattedMessage
        id='annual_report.summary.highlighted_post.by_favourites'
        defaultMessage='most favourited post'
      />
    );
  } else {
    statusId = data.by_replies;
    label = (
      <FormattedMessage
        id='annual_report.summary.highlighted_post.by_replies'
        defaultMessage='post with the most replies'
      />
    );
  }

  const dispatch = useAppDispatch();
  const domain = useAppSelector((state) => state.meta.get('domain'));
  const status = useAppSelector((state) =>
    statusId ? getStatus(state, { id: statusId }) : undefined,
  );
  const pictureInPicture = useAppSelector((state) =>
    statusId ? getPictureInPicture(state, { id: statusId }) : undefined,
  );
  const account = useAppSelector((state) =>
    me ? state.accounts.get(me) : undefined,
  );

  const handleToggleHidden = useCallback(() => {
    dispatch(toggleStatusSpoilers(statusId));
  }, [dispatch, statusId]);

  if (!status) {
    return (
      <div className='annual-report__bento__box annual-report__summary__most-boosted-post' />
    );
  }

  const displayName = (
    <span className='display-name'>
      <strong className='display-name__html'>
        <FormattedMessage
          id='annual_report.summary.highlighted_post.possessive'
          defaultMessage="{name}'s"
          values={{
            name: account && (
              <bdi
                dangerouslySetInnerHTML={{ __html: account.display_name_html }}
              />
            ),
          }}
        />
      </strong>
      <span className='display-name__account'>{label}</span>
    </span>
  );

  return (
    <div className='annual-report__bento__box annual-report__summary__most-boosted-post'>
      <DetailedStatus
        status={status}
        pictureInPicture={pictureInPicture}
        domain={domain}
        onToggleHidden={handleToggleHidden}
        overrideDisplayName={displayName}
      />
    </div>
  );
};
