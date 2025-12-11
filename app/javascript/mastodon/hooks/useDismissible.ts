import { useCallback, useState, useEffect } from 'react';

import type { Map as ImmutableMap } from 'immutable';

import { changeSetting } from '@/mastodon/actions/settings';
import { bannerSettings } from '@/mastodon/settings';
import { useAppSelector, useAppDispatch } from '@/mastodon/store';

export function useDismissible(id: string) {
  // We use "dismissed_banners" as that was what this was previously called,
  // but we can use this to track any dismissible state.
  const dismissed = useAppSelector(
    (state) =>
      !!(
        state.settings as ImmutableMap<
          'dismissed_banners',
          ImmutableMap<string, boolean>
        >
      ).getIn(['dismissed_banners', id], false),
  );

  const [isVisible, setIsVisible] = useState(
    !bannerSettings.get(id) && !dismissed,
  );

  const dispatch = useAppDispatch();

  const dismiss = useCallback(() => {
    setIsVisible(false);
    bannerSettings.set(id, true);
    dispatch(changeSetting(['dismissed_banners', id], true));
  }, [id, dispatch]);

  useEffect(() => {
    // Store legacy localStorage setting on server
    if (!isVisible && !dismissed) {
      dispatch(changeSetting(['dismissed_banners', id], true));
    }
  }, [id, dispatch, isVisible, dismissed]);

  return {
    wasDismissed: !isVisible,
    dismiss,
  };
}
