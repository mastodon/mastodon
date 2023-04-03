// @ts-check

/**
 * @typedef Emoji
 * @property {string} shortcode
 * @property {string} static_url
 * @property {string} url
 */

/**
 * @typedef AccountField
 * @property {string} name
 * @property {string} value
 * @property {string} verified_at
 */

/**
 * @typedef Account
 * @property {string} acct
 * @property {string} avatar
 * @property {string} avatar_static
 * @property {boolean} bot
 * @property {string} created_at
 * @property {boolean=} discoverable
 * @property {string} display_name
 * @property {Emoji[]} emojis
 * @property {AccountField[]} fields
 * @property {number} followers_count
 * @property {number} following_count
 * @property {boolean} group
 * @property {string} header
 * @property {string} header_static
 * @property {string} id
 * @property {string=} last_status_at
 * @property {boolean} locked
 * @property {string} note
 * @property {number} statuses_count
 * @property {string} url
 * @property {string} username
 */

/**
 * @typedef {[code: string, name: string, localName: string]} InitialStateLanguage
 */

/**
 * @typedef InitialStateMeta
 * @property {string} access_token
 * @property {boolean=} advanced_layout
 * @property {boolean} auto_play_gif
 * @property {boolean} activity_api_enabled
 * @property {string} admin
 * @property {boolean=} boost_modal
 * @property {boolean} crop_images
 * @property {boolean=} delete_modal
 * @property {boolean=} disable_swiping
 * @property {string=} disabled_account_id
 * @property {boolean} display_media
 * @property {string} domain
 * @property {boolean=} expand_spoilers
 * @property {boolean} limited_federation_mode
 * @property {string} locale
 * @property {string | null} mascot
 * @property {string=} me
 * @property {string=} moved_to_account_id
 * @property {string=} owner
 * @property {boolean} profile_directory
 * @property {boolean} registrations_open
 * @property {boolean} reduce_motion
 * @property {string} repository
 * @property {boolean} search_enabled
 * @property {boolean} single_user_mode
 * @property {string} source_url
 * @property {string} streaming_api_base_url
 * @property {boolean} timeline_preview
 * @property {string} title
 * @property {boolean} trends
 * @property {boolean} trends_as_landing_page
 * @property {boolean} unfollow_modal
 * @property {boolean} use_blurhash
 * @property {boolean=} use_pending_items
 * @property {string} version
 */

/**
 * @typedef InitialState
 * @property {Record<string, Account>} accounts
 * @property {InitialStateLanguage[]} languages
 * @property {InitialStateMeta} meta
 */

const element = document.getElementById('initial-state');
/** @type {InitialState | undefined} */
const initialState = element?.textContent && JSON.parse(element.textContent);

/**
 * @template {keyof InitialStateMeta} K
 * @param {K} prop
 * @returns {InitialStateMeta[K] | undefined}
 */
const getMeta = (prop) => initialState?.meta && initialState.meta[prop];

export const activityApiEnabled = getMeta('activity_api_enabled');
export const autoPlayGif = getMeta('auto_play_gif');
export const boostModal = getMeta('boost_modal');
export const cropImages = getMeta('crop_images');
export const deleteModal = getMeta('delete_modal');
export const disableSwiping = getMeta('disable_swiping');
export const disabledAccountId = getMeta('disabled_account_id');
export const displayMedia = getMeta('display_media');
export const domain = getMeta('domain');
export const expandSpoilers = getMeta('expand_spoilers');
export const forceSingleColumn = !getMeta('advanced_layout');
export const limitedFederationMode = getMeta('limited_federation_mode');
export const mascot = getMeta('mascot');
export const me = getMeta('me');
export const movedToAccountId = getMeta('moved_to_account_id');
export const owner = getMeta('owner');
export const profile_directory = getMeta('profile_directory');
export const reduceMotion = getMeta('reduce_motion');
export const registrationsOpen = getMeta('registrations_open');
export const repository = getMeta('repository');
export const searchEnabled = getMeta('search_enabled');
export const showTrends = getMeta('trends');
export const singleUserMode = getMeta('single_user_mode');
export const source_url = getMeta('source_url');
export const timelinePreview = getMeta('timeline_preview');
export const title = getMeta('title');
export const trendsAsLanding = getMeta('trends_as_landing_page');
export const unfollowModal = getMeta('unfollow_modal');
export const useBlurhash = getMeta('use_blurhash');
export const usePendingItems = getMeta('use_pending_items');
export const version = getMeta('version');
export const languages = initialState?.languages;
// @ts-expect-error
export const statusPageUrl = getMeta('status_page_url');

// Glitch-soc-specific settings
export const maxChars = (initialState && initialState.max_toot_chars) || 500;

export default initialState;
