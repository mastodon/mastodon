import {
  isClientFeatureEnabled,
  isServerFeatureEnabled,
} from '@/mastodon/utils/environment';

export function areCollectionsEnabled() {
  return (
    isClientFeatureEnabled('collections') &&
    isServerFeatureEnabled('collections')
  );
}
