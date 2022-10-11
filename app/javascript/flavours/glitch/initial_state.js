const element = document.getElementById('initial-state');
const initialState = element && JSON.parse(element.textContent);

// Glitch-soc-specific “local settings”
try {
  initialState.local_settings = JSON.parse(localStorage.getItem('mastodon-settings'));
} catch (e) {
  initialState.local_settings = {};
}

const getMeta = (prop) => initialState && initialState.meta && initialState.meta[prop];

export const domain = getMeta('domain');
export const reduceMotion = getMeta('reduce_motion');
export const autoPlayGif = getMeta('auto_play_gif');
export const displayMedia = getMeta('display_media');
export const expandSpoilers = getMeta('expand_spoilers');
export const unfollowModal = getMeta('unfollow_modal');
export const boostModal = getMeta('boost_modal');
export const deleteModal = getMeta('delete_modal');
export const me = getMeta('me');
export const searchEnabled = getMeta('search_enabled');
export const maxChars = (initialState && initialState.max_toot_chars) || 500;
export const limitedFederationMode = getMeta('limited_federation_mode');
export const registrationsOpen = getMeta('registrations_open');
export const repository = getMeta('repository');
export const source_url = getMeta('source_url');
export const version = getMeta('version');
export const mascot = getMeta('mascot');
export const profile_directory = getMeta('profile_directory');
export const forceSingleColumn = !getMeta('advanced_layout');
export const useBlurhash = getMeta('use_blurhash');
export const usePendingItems = getMeta('use_pending_items');
export const showTrends = getMeta('trends');
export const title = getMeta('title');
export const disableSwiping = getMeta('disable_swiping');
export const languages = initialState && initialState.languages;

// Glitch-soc-specific settings
export const favouriteModal = getMeta('favourite_modal');
export const pollLimits = (initialState && initialState.poll_limits);
export const defaultContentType = getMeta('default_content_type');
export const useSystemEmojiFont = getMeta('system_emoji_font');

export default initialState;
