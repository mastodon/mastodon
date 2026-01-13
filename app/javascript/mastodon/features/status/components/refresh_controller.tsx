import { useEffect, useState, useCallback, useMemo } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import { useDebouncedCallback } from 'use-debounce';

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
import { useInterval } from 'mastodon/hooks/useInterval';
import { useIsDocumentVisible } from 'mastodon/hooks/useIsDocumentVisible';
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
    defaultMessage: 'New replies loaded',
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

/**
 * Age of thread below which we consider it new & fetch
 * replies more frequently
 */
const NEW_THREAD_AGE_THRESHOLD = 30 * 60_000;
/**
 * Interval at which we check for new replies for old threads
 */
const LONG_AUTO_FETCH_REPLIES_INTERVAL = 5 * 60_000;
/**
 * Interval at which we check for new replies for new threads.
 * Also used as a threshold to throttle repeated fetch calls
 */
const SHORT_AUTO_FETCH_REPLIES_INTERVAL = 60_000;
/**
 * Number of refresh_async checks at which an early fetch
 * will be triggered if there are results
 */
const LONG_RUNNING_FETCH_THRESHOLD = 3;

/**
 * Returns whether the thread is new, based on NEW_THREAD_AGE_THRESHOLD
 */
function getIsThreadNew(statusCreatedAt: string) {
  const now = new Date();
  const newThreadThreshold = new Date(now.getTime() - NEW_THREAD_AGE_THRESHOLD);

  return new Date(statusCreatedAt) > newThreadThreshold;
}

/**
 * This hook kicks off a background check for the async refresh job
 * and loads any newly found replies once the job has finished,
 * and when LONG_RUNNING_FETCH_THRESHOLD was reached and replies were found
 */
function useCheckForRemoteReplies({
  statusId,
  refreshHeader,
  isEnabled,
  onChangeLoadingState,
}: {
  statusId: string;
  refreshHeader?: AsyncRefreshHeader;
  isEnabled: boolean;
  onChangeLoadingState: React.Dispatch<React.SetStateAction<LoadingState>>;
}) {
  const dispatch = useAppDispatch();

  useEffect(() => {
    let timeoutId: ReturnType<typeof setTimeout>;

    const scheduleRefresh = (
      refresh: AsyncRefreshHeader,
      iteration: number,
    ) => {
      timeoutId = setTimeout(() => {
        void apiGetAsyncRefresh(refresh.id).then((result) => {
          const { status, result_count } = result.async_refresh;

          // At three scheduled refreshes, we consider the job
          // long-running and attempt to fetch any new replies so far
          const isLongRunning = iteration === LONG_RUNNING_FETCH_THRESHOLD;

          // If the refresh status is not finished and not long-running,
          // we just schedule another refresh and exit
          if (status === 'running' && !isLongRunning) {
            scheduleRefresh(refresh, iteration + 1);
            return;
          }

          // If refresh status is finished, clear `refreshHeader`
          // (we don't want to do this if it's just a long-running job)
          if (status === 'finished') {
            dispatch(completeContextRefresh({ statusId }));
          }

          // Exit if there's nothing to fetch
          if (result_count === 0) {
            if (status === 'finished') {
              onChangeLoadingState('idle');
            } else {
              scheduleRefresh(refresh, iteration + 1);
            }
            return;
          }

          // A positive result count means there _might_ be new replies,
          // so we fetch the context in the background to check if there
          // are any new replies.
          // If so, they will populate `contexts.pendingReplies[statusId]`
          void dispatch(fetchContext({ statusId, prefetchOnly: true }))
            .then(() => {
              // Reset loading state to `idle`. If the fetch has
              // resulted in new pending replies, the `hasPendingReplies`
              // flag will switch the loading state to 'more-available'
              if (status === 'finished') {
                onChangeLoadingState('idle');
              } else {
                // Keep background fetch going if `isLongRunning` is true
                scheduleRefresh(refresh, iteration + 1);
              }
            })
            .catch(() => {
              // Show an error if the fetch failed
              onChangeLoadingState('error');
            });
        });
      }, refresh.retry * 1000);
    };

    // Initialise a refresh
    if (refreshHeader && isEnabled) {
      scheduleRefresh(refreshHeader, 1);
      onChangeLoadingState('loading');
    }

    return () => {
      clearTimeout(timeoutId);
    };
  }, [onChangeLoadingState, dispatch, statusId, refreshHeader, isEnabled]);
}

/**
 * This component fetches new post replies in the background
 * and gives users the option to show them.
 *
 * The following three scenarios are handled:
 *
 * 1. When the browser tab is visible, replies are refetched periodically
 *    (more frequently for new posts, less frequently for old ones)
 * 2. Replies are refetched when the browser tab is refocused
 *    after it was hidden or minimised
 * 3. For remote posts, remote replies that might not yet be known to the
 *    server are imported & fetched using the AsyncRefresh API.
 */
export const RefreshController: React.FC<{
  statusId: string;
  statusCreatedAt: string;
  isLocal: boolean;
}> = ({ statusId, statusCreatedAt, isLocal }) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();

  const refreshHeader = useAppSelector((state) =>
    isLocal ? undefined : state.contexts.refreshing[statusId],
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

  // Prevent too-frequent context calls
  const debouncedFetchContext = useDebouncedCallback(
    () => {
      void dispatch(fetchContext({ statusId, prefetchOnly: true }));
    },
    // Ensure the debounce is a bit shorter than the auto-fetch interval
    SHORT_AUTO_FETCH_REPLIES_INTERVAL - 500,
    {
      leading: true,
      trailing: false,
    },
  );

  const isDocumentVisible = useIsDocumentVisible({
    onChange: (isVisible) => {
      // Auto-fetch new replies when the page is refocused
      if (isVisible && partialLoadingState !== 'loading' && !wasDismissed) {
        debouncedFetchContext();
      }
    },
  });

  // Check for remote replies
  useCheckForRemoteReplies({
    statusId,
    refreshHeader,
    isEnabled: isDocumentVisible && !isLocal && !wasDismissed,
    onChangeLoadingState: setLoadingState,
  });

  // Only auto-fetch new replies if there's no ongoing remote replies check
  const shouldAutoFetchReplies =
    isDocumentVisible && partialLoadingState !== 'loading' && !wasDismissed;

  const autoFetchInterval = useMemo(
    () =>
      getIsThreadNew(statusCreatedAt)
        ? SHORT_AUTO_FETCH_REPLIES_INTERVAL
        : LONG_AUTO_FETCH_REPLIES_INTERVAL,
    [statusCreatedAt],
  );

  useInterval(debouncedFetchContext, {
    delay: autoFetchInterval,
    isEnabled: shouldAutoFetchReplies,
  });

  useEffect(() => {
    // Hide success message after a short delay
    if (loadingState === 'success') {
      const timeoutId = setTimeout(() => {
        setLoadingState('idle');
      }, 2500);

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

  const showPending = useCallback(() => {
    dispatch(showPendingReplies({ statusId }));
    setLoadingState('success');
  }, [dispatch, statusId]);

  if (loadingState === 'loading') {
    return (
      <div
        className='load-more load-more--large'
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
        onActionClick={showPending}
        onDismiss={dismissPrompt}
        animateFrom='below'
      />
      <AnimatedAlert
        withEntryDelay
        isActive={loadingState === 'error'}
        message={intl.formatMessage(messages.error)}
        action={intl.formatMessage(messages.retry)}
        onActionClick={showPending}
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
