import { useEffect, useState, useCallback } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import {
  fetchContext,
  completeContextRefresh,
  showPendingReplies,
  clearPendingReplies,
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

type LoadingState = 'idle' | 'more-available' | 'loading' | 'success' | 'error';

export const RefreshController: React.FC<{
  statusId: string;
}> = ({ statusId }) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();

  const refreshHeader = useAppSelector(
    (state) => state.contexts.refreshing[statusId],
  );
  const hasPendingReplies = useAppSelector(
    (state) => !!state.contexts.pendingReplies[statusId]?.length,
  );
  const [partialLoadingState, setLoadingState] = useState<LoadingState>(
    refreshHeader ? 'loading' : 'idle',
  );
  const loadingState = hasPendingReplies
    ? 'more-available'
    : partialLoadingState;

  const [wasDismissed, setWasDismissed] = useState(false);
  const dismissPrompt = useCallback(() => {
    setWasDismissed(true);
    setLoadingState('idle');
    dispatch(clearPendingReplies({ statusId }));
  }, [dispatch, statusId]);

  useEffect(() => {
    let timeoutId: ReturnType<typeof setTimeout>;

    const scheduleRefresh = (refresh: AsyncRefreshHeader) => {
      timeoutId = setTimeout(() => {
        void apiGetAsyncRefresh(refresh.id).then((result) => {
          // If the refresh status is not finished,
          // schedule another refresh and exit
          if (result.async_refresh.status !== 'finished') {
            scheduleRefresh(refresh);
            return;
          }

          // Refresh status is finished. The action below will clear `refreshHeader`
          dispatch(completeContextRefresh({ statusId }));

          // Exit if there's nothing to fetch
          if (result.async_refresh.result_count === 0) {
            setLoadingState('idle');
            return;
          }

          // A positive result count means there _might_ be new replies,
          // so we fetch the context in the background to check if there
          // are any new replies.
          // If so, they will populate `contexts.pendingReplies[statusId]`
          void dispatch(fetchContext({ statusId, prefetchOnly: true }))
            .then(() => {
              // Reset loading state to `idle` – but if the fetch
              // has resulted in new pending replies, the `hasPendingReplies`
              // flag will switch the loading state to 'more-available'
              setLoadingState('idle');
            })
            .catch(() => {
              // Show an error if the fetch failed
              setLoadingState('error');
            });
        });
      }, refresh.retry * 1000);
    };

    // Initialise a refresh
    if (refreshHeader && !wasDismissed) {
      scheduleRefresh(refreshHeader);
      setLoadingState('loading');
    }

    return () => {
      clearTimeout(timeoutId);
    };
  }, [dispatch, statusId, refreshHeader, wasDismissed]);

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

  useEffect(() => {
    // Clear pending replies on unmount
    return () => {
      dispatch(clearPendingReplies({ statusId }));
    };
  }, [dispatch, statusId]);

  const handleClick = useCallback(() => {
    dispatch(showPendingReplies({ statusId }));
    setLoadingState('success');
  }, [dispatch, statusId]);

  if (loadingState === 'loading') {
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
