import { isClientFeatureEnabled } from '@/mastodon/utils/environment';

export function areCollectionsEnabled() {
  return isClientFeatureEnabled('collections');
}
