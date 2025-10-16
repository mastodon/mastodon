import { initialState } from '../initial_state';

export function isDevelopment() {
  if (typeof process !== 'undefined')
    return process.env.NODE_ENV === 'development';
  else return import.meta.env.DEV;
}

export function isProduction() {
  if (typeof process !== 'undefined')
    return process.env.NODE_ENV === 'production';
  else return import.meta.env.PROD;
}

export type Features = 'modern_emojis' | 'fasp' | 'http_message_signatures';

export function isFeatureEnabled(feature: Features) {
  return initialState?.features.includes(feature) ?? false;
}

export function isModernEmojiEnabled() {
  try {
    return isFeatureEnabled('modern_emojis');
  } catch {
    return false;
  }
}
