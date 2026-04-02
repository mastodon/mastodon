import { isServerFeatureEnabled } from '@/mastodon/utils/environment';

export function areCollectionsEnabled() {
  return isServerFeatureEnabled('collections');
}
