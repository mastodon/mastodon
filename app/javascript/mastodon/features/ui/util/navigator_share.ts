import { supportsNativeShare } from 'mastodon/utils/browser_support';
import { toError } from 'mastodon/utils/to_error';

interface ShareData extends Record<string, unknown> {
  url?: string;
  text?: string;
  title?: string;
  files?: File[];
}

export const navigatorShare = async (
  data: Record<keyof ShareData, unknown>,
): Promise<void> => {
  try {
    if (supportsNativeShare) {
      await navigator.share(data);
      return;
    }
  } catch (err) {
    const error = toError(err);
    if (error.name === 'AbortError') {
      // An abort error occurs when the user cancels the share action.
      return;
    }
    throw error;
  }
};
