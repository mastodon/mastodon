const element = document.getElementById('initial-state');
const initialState = element && JSON.parse(element.textContent);

const getMeta = (prop) => initialState && initialState.meta && initialState.meta[prop];

export const reduceMotion = getMeta('reduce_motion');
export const timelineInjectionRate = getMeta('timeline_injection_rate');
export const adInjectionRate = getMeta('ad_injection_rate');
export const googleAdClient = getMeta('google_ad_client');
export const googleAdSlot = getMeta('google_ad_slot');
export const googleAdLayoutKey = getMeta('google_ad_layout_key');
export const autoPlayGif = getMeta('auto_play_gif');
export const displayMedia = getMeta('display_media');
export const expandSpoilers = getMeta('expand_spoilers');
export const unfollowModal = getMeta('unfollow_modal');
export const boostModal = getMeta('boost_modal');
export const deleteModal = getMeta('delete_modal');
export const me = getMeta('me');
export const searchEnabled = getMeta('search_enabled');
export const invitesEnabled = getMeta('invites_enabled');
export const repository = getMeta('repository');
export const source_url = getMeta('source_url');
export const version = getMeta('version');
export const mascot = getMeta('mascot');
export const profile_directory = getMeta('profile_directory');
export const isStaff = getMeta('is_staff');
export const forceSingleColumn = !getMeta('advanced_layout');
export const useBlurhash = getMeta('use_blurhash');
export const usePendingItems = getMeta('use_pending_items');
export const showTrends = getMeta('trends');
export const title = getMeta('title');
export const cropImages = getMeta('crop_images');
export const disableSwiping = getMeta('disable_swiping');

export const AD_INJECTION_COMPONENT = 'AD_INJECTION_COMPONENT';

export default initialState;
