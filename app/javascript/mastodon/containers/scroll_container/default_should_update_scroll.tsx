import type { MastodonLocation } from 'mastodon/components/router';

export type ShouldUpdateScrollFn = (
  prevLocationContext: MastodonLocation | null,
  locationContext: MastodonLocation,
) => boolean;

/**
 * ScrollBehavior will automatically scroll to the top on navigations
 * or restore saved scroll positions, but on some location changes we
 * need to prevent this.
 */

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
