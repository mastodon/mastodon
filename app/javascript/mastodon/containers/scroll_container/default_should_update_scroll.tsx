import type { MastodonLocation } from 'mastodon/components/router';

export type ShouldUpdateScrollFn = (
  prevLocationContext: MastodonLocation | null,
  locationContext: MastodonLocation,
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
