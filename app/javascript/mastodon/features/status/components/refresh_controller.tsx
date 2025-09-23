import { useEffect, useState, useCallback } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import {
  fetchContext,
  completeContextRefresh,
} from 'mastodon/actions/statuses';
import type { AsyncRefreshHeader } from 'mastodon/api';
import { apiGetAsyncRefresh } from 'mastodon/api/async_refreshes';
import { Alert } from 'mastodon/components/alert';
import { ExitAnimationWrapper } from 'mastodon/components/exit_animation_wrapper';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

const AnimatedAlert: React.FC<
  React.ComponentPropsWithoutRef<typeof Alert> & { withEntryDelay?: boolean }
> = ({ isActive = false, withEntryDelay, ...props }) => (
  <ExitAnimationWrapper withEntryDelay isActive={isActive}>
    {(delayedIsActive) => <Alert isActive={delayedIsActive} {...props} />}
  </ExitAnimationWrapper>
);

const messages = defineMessages({
  moreFound: {
    id: 'status.context.more_replies_found',
    defaultMessage: 'More replies found',
  },
  show: {
    id: 'status.context.show',
    defaultMessage: 'Show',
  },
  loadingInitial: {
    id: 'status.context.loading',
    defaultMessage: 'Loading',
  },
  loadingMore: {
    id: 'status.context.loading_more',
    defaultMessage: 'Loading more replies',
  },
  success: {
    id: 'status.context.loading_success',
    defaultMessage: 'All replies loaded',
  },
  error: {
    id: 'status.context.loading_error',
    defaultMessage: "Couldn't load new replies",
  },
  retry: {
    id: 'status.context.retry',
    defaultMessage: 'Retry',
  },
});

type LoadingState =
  | 'idle'
  | 'more-available'
  | 'loading-initial'
  | 'loading-more'
  | 'success'
  | 'error';

export const RefreshController: React.FC<{
  statusId: string;
}> = ({ statusId }) => {
  const refresh = useAppSelector(
    (state) => state.contexts.refreshing[statusId],
  );
  const currentReplyCount = useAppSelector(
    (state) => state.contexts.replies[statusId]?.length ?? 0,
  );
  const autoRefresh = !currentReplyCount;
  const dispatch = useAppDispatch();
  const intl = useIntl();

  const [loadingState, setLoadingState] = useState<LoadingState>(
    refresh && autoRefresh ? 'loading-initial' : 'idle',
  );

  const [wasDismissed, setWasDismissed] = useState(false);
  const dismissPrompt = useCallback(() => {
    setWasDismissed(true);
    setLoadingState('idle');
  }, []);

  useEffect(() => {
    let timeoutId: ReturnType<typeof setTimeout>;

    const scheduleRefresh = (refresh: AsyncRefreshHeader) => {
      timeoutId = setTimeout(() => {
        void apiGetAsyncRefresh(refresh.id).then((result) => {
          if (result.async_refresh.status === 'finished') {
            dispatch(completeContextRefresh({ statusId }));

            if (result.async_refresh.result_count > 0) {
              if (autoRefresh) {
                void dispatch(fetchContext({ statusId })).then(() => {
                  setLoadingState('idle');
                });
              } else {
                setLoadingState('more-available');
              }
            } else {
              setLoadingState('idle');
            }
          } else {
            scheduleRefresh(refresh);
          }
        });
      }, refresh.retry * 1000);
    };

    if (refresh && !wasDismissed) {
      scheduleRefresh(refresh);
      setLoadingState('loading-initial');
    }

    return () => {
      clearTimeout(timeoutId);
    };
  }, [dispatch, statusId, refresh, autoRefresh, wasDismissed]);

  useEffect(() => {
    // Hide success message after a short delay
    if (loadingState === 'success') {
      const timeoutId = setTimeout(() => {
        setLoadingState('idle');
      }, 3000);

      return () => {
        clearTimeout(timeoutId);
      };
    }
    return () => '';
  }, [loadingState]);

  const handleClick = useCallback(() => {
    setLoadingState('loading-more');

    dispatch(fetchContext({ statusId }))
      .then(() => {
        setLoadingState('success');
        return '';
      })
      .catch(() => {
        setLoadingState('error');
      });
  }, [dispatch, statusId]);

  if (loadingState === 'loading-initial') {
    return (
      <div
        className='load-more load-gap'
        aria-busy
        aria-live='polite'
        aria-label={intl.formatMessage(messages.loadingInitial)}
      >
        <LoadingIndicator />
      </div>
    );
  }

  return (
    <div className='column__alert' role='status' aria-live='polite'>
      <AnimatedAlert
        isActive={loadingState === 'more-available'}
        message={intl.formatMessage(messages.moreFound)}
        action={intl.formatMessage(messages.show)}
        onActionClick={handleClick}
        onDismiss={dismissPrompt}
        animateFrom='below'
      />
      <AnimatedAlert
        isLoading
        withEntryDelay
        isActive={loadingState === 'loading-more'}
        message={intl.formatMessage(messages.loadingMore)}
        animateFrom='below'
      />
      <AnimatedAlert
        withEntryDelay
        isActive={loadingState === 'error'}
        message={intl.formatMessage(messages.error)}
        action={intl.formatMessage(messages.retry)}
        onActionClick={handleClick}
        onDismiss={dismissPrompt}
        animateFrom='below'
      />
      <AnimatedAlert
        withEntryDelay
        isActive={loadingState === 'success'}
        message={intl.formatMessage(messages.success)}
        animateFrom='below'
      />
    </div>
  );
};
