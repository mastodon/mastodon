const element = document.getElementById('initial-state');
const initialState = element && function () {
  const result = JSON.parse(element.textContent);
  try {
    result.local_settings = JSON.parse(localStorage.getItem('mastodon-settings'));
  } catch (e) {
    result.local_settings = {};
  }
  return result;
}();

const getMeta = (prop) => initialState && initialState.meta && initialState.meta[prop];

export const reduceMotion = getMeta('reduce_motion');
export const autoPlayGif = getMeta('auto_play_gif');
export const displaySensitiveMedia = getMeta('display_sensitive_media');
export const displayMedia = getMeta('display_media') || (getMeta('display_sensitive_media') ? 'show_all' : 'default');
export const unfollowModal = getMeta('unfollow_modal');
export const boostModal = getMeta('boost_modal');
export const favouriteModal = getMeta('favourite_modal');
export const deleteModal = getMeta('delete_modal');
export const me = getMeta('me');
export const searchEnabled = getMeta('search_enabled');
export const maxChars = (initialState && initialState.max_toot_chars) || 500;
export const pollLimits = (initialState && initialState.poll_limits);
export const invitesEnabled = getMeta('invites_enabled');
export const version = getMeta('version');
export const mascot = getMeta('mascot');
export const profile_directory = getMeta('profile_directory');
export const isStaff = getMeta('is_staff');
export const defaultContentType = getMeta('default_content_type');
export const forceSingleColumn = getMeta('advanced_layout') === false;
export const useBlurhash = getMeta('use_blurhash');
export const usePendingItems = getMeta('use_pending_items');
export const useSystemEmojiFont = getMeta('system_emoji_font');
export const showTrends = getMeta('trends');

export default initialState;
