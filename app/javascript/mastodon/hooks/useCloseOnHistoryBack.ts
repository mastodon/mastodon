import { useEffect, useEffectEvent } from 'react';

import { useHistory } from 'react-router';

import type { LocationState } from '@/mastodon/components/router';
import { IGNORE_FOCUS_ON_OPEN } from '@/mastodon/reducers/modal';

/**
 * Hook to allow closing dialogs or overlays using the browser back button
 * if they don't naturally have their own URL/history entry.
 * When active, the hook adds a new history entry setting a `mastodonModalKey`,
 * and calls the passed `onClose` handler when navigating back.
 *
 * This leads to pollution of the browser history with
 * "meaningless" modal key entries and in the future we should
 * implement the new CloseWatcher API for this functionality instead.
 */
export function useCloseOnHistoryBack(
  onClose: () => void,
  {
    active = true,
    ignoreFocus = false,
  }: {
    active?: boolean;
    ignoreFocus?: boolean | typeof IGNORE_FOCUS_ON_OPEN;
  } = {},
) {
  const history = useHistory<LocationState>();
  const close = useEffectEvent(onClose);
  const getFocusTarget = useEffectEvent(
    () => ignoreFocus !== IGNORE_FOCUS_ON_OPEN,
  );

  useEffect(() => {
    if (!active) {
      return;
    }

    const key = `${Date.now()}`;

    const { pathname, search, hash, state } = history.location;

    if (state?.mastodonModalKey !== key) {
      history.push(
        { pathname, search, hash },
        {
          ...state,
          focusTarget: getFocusTarget(),
          mastodonModalKey: key,
        },
      );
    }

    const unlisten = history.listen((newLocation, action) => {
      if (action === 'POP' && newLocation.state?.mastodonModalKey !== key) {
        close();
      }
    });

    return () => {
      unlisten();

      if (state?.mastodonModalKey === key) {
        history.goBack();
      }
    };
  }, [history, active]);
}
