import { isServerFeatureEnabled } from '@/mastodon/utils/environment';

export function areCollectionsEnabled() {
  return isServerFeatureEnabled('collections');
}

export const getCollectionPath = (id: string) => `/collections/${id}`;
