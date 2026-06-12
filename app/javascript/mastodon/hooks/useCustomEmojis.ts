import { selectCustomEmojis } from '@/mastodon/reducers/slices/emojis';
import { useAppSelector } from '@/mastodon/store';

export function useCustomEmojis() {
  return useAppSelector(selectCustomEmojis);
}
