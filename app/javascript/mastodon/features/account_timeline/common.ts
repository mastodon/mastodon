import { isClientFeatureEnabled } from '@/mastodon/utils/environment';

export function isRedesignEnabled() {
  return isClientFeatureEnabled('profile_redesign');
}
