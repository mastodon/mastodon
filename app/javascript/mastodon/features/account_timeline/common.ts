import { isServerFeatureEnabled } from '@/mastodon/utils/environment';

export function isRedesignEnabled() {
  return isServerFeatureEnabled('profile_redesign');
}
