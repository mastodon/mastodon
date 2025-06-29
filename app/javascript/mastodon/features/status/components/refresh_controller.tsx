import { useEffect, useState, useCallback } from 'react';

import { useIntl, defineMessages, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import {
  fetchContext,
  completeContextRefresh,
} from 'mastodon/actions/statuses';
import type { AsyncRefreshHeader } from 'mastodon/api';
import { apiGetAsyncRefresh } from 'mastodon/api/async_refreshes';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  loading: {
    id: 'status.context.loading',
    defaultMessage: 'Checking for more replies',
  },
});

export const RefreshController: React.FC<{
  statusId: string;
  withBorder?: boolean;
}> = ({ statusId, withBorder }) => {
  const refresh = useAppSelector(
    (state) => state.contexts.refreshing[statusId],
  );
  const dispatch = useAppDispatch();
  const intl = useIntl();
  const [ready, setReady] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    let timeoutId: ReturnType<typeof setTimeout>;

    const scheduleRefresh = (refresh: AsyncRefreshHeader) => {
      timeoutId = setTimeout(() => {
        void apiGetAsyncRefresh(refresh.id).then((result) => {
          if (result.async_refresh.status === 'finished') {
            dispatch(completeContextRefresh({ statusId }));

            if (result.async_refresh.result_count > 0) {
              setReady(true);
            }
          } else {
            scheduleRefresh(refresh);
          }

          return '';
        });
      }, refresh.retry * 1000);
    };

    if (refresh) {
      scheduleRefresh(refresh);
    }

    return () => {
      clearTimeout(timeoutId);
    };
  }, [dispatch, setReady, statusId, refresh]);

  const handleClick = useCallback(() => {
    setLoading(true);
    setReady(false);

    dispatch(fetchContext({ statusId }))
      .then(() => {
        setLoading(false);
        return '';
      })
      .catch(() => {
        setLoading(false);
      });
  }, [dispatch, setReady, statusId]);

  if (ready && !loading) {
    return (
      <button
        className={classNames('load-more load-gap', {
          'timeline-hint--with-descendants': withBorder,
        })}
        onClick={handleClick}
      >
        <FormattedMessage
          id='status.context.load_new_replies'
          defaultMessage='New replies available'
        />
      </button>
    );
  }

  if (!refresh && !loading) {
    return null;
  }

  return (
    <div
      className={classNames('load-more load-gap', {
        'timeline-hint--with-descendants': withBorder,
      })}
      aria-busy
      aria-live='polite'
      aria-label={intl.formatMessage(messages.loading)}
    >
      <LoadingIndicator />
    </div>
  );
};
