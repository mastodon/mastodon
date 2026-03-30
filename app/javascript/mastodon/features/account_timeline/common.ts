import type { AccountFieldShape } from '@/mastodon/models/account';
import { isServerFeatureEnabled } from '@/mastodon/utils/environment';

export function isRedesignEnabled() {
  return isServerFeatureEnabled('profile_redesign');
}

export interface AccountField extends AccountFieldShape {
  nameHasEmojis: boolean;
  value_plain: string;
  valueHasEmojis: boolean;
}
