import { useEffect, useId } from 'react';

import { FormattedMessage } from 'react-intl';

import type { Map as ImmutableMap } from 'immutable';
import { List as ImmutableList } from 'immutable';


import { expandAccountFeaturedTimeline } from '@/mastodon/actions/timelines';
import StatusContainer from '@/mastodon/containers/status_container';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import PushPinIcon from '@/material-icons/400-24px/push_pin.svg?react';

import { Icon } from './icon';


export const FeaturedCarousel: React.FC<{
  accountId: string;
  tagged?: string;
}> = ({ accountId, tagged }) => {
  const accessibilityId = useId();

  // Load pinned statuses
  const dispatch = useAppDispatch();
  useEffect(() => {
    if (accountId) {
      void dispatch(expandAccountFeaturedTimeline(accountId, { tagged }));
    }
  }, [accountId, dispatch, tagged]);
  const pinnedStatuses = useAppSelector(
    (state) =>
      (state.timelines as ImmutableMap<string, unknown>).getIn(
        [`account:${accountId}:pinned${tagged ? `:${tagged}` : ''}`, 'items'],
        ImmutableList(),
      ) as ImmutableList<string>,
  );


  if (!accountId || pinnedStatuses.isEmpty()) {
    return null;
  }

  return (
    <div>
      {pinnedStatuses.map((statusId) => (
        <div
          key={statusId}
          className='featured-carousel'
          aria-labelledby={`${accessibilityId}-title`}
          role='region'
        >
          <div className='featured-carousel__header'>
            <h4
              className='featured-carousel__title'
              id={`${accessibilityId}-title`}
            >
              <Icon id='thumb-tack' icon={PushPinIcon} />
              <FormattedMessage
                id='column.pins'
                defaultMessage='Pinned post'
              />
            </h4>
          </div>
          <StatusContainer
            // @ts-expect-error inferred props are wrong
            id={statusId}
            contextType='account'
            withCounters
          />
        </div>
      ))}
    </div>
  );
};
