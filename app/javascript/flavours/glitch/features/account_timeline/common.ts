import type { AccountFieldShape } from '@/flavours/glitch/models/account';
import { isServerFeatureEnabled } from '@/flavours/glitch/utils/environment';

export function isRedesignEnabled() {
  return isServerFeatureEnabled('profile_redesign');
}

export interface AccountField extends AccountFieldShape {
  nameHasEmojis: boolean;
  value_plain: string;
  valueHasEmojis: boolean;
}
