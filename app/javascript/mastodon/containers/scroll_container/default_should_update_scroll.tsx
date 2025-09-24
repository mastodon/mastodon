import type { useLocation } from 'react-router';

import type { MastodonLocationState } from 'mastodon/components/router';

export type LocationContext = ReturnType<
  typeof useLocation<MastodonLocationState | undefined>
>;

export type ShouldUpdateScrollFn = (
  prevLocationContext: LocationContext | null,
  locationContext: LocationContext,
) => boolean;

export const defaultShouldUpdateScroll: ShouldUpdateScrollFn = (
  prevLocation,
  location,
) => {
  // If the change is caused by opening a modal, do not scroll to top
  const shouldUpdateScroll = !(
    location.state?.mastodonModalKey &&
    location.state.mastodonModalKey !== prevLocation?.state?.mastodonModalKey
  );

  return shouldUpdateScroll;
};
