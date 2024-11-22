// @ts-check


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
 * @property {boolean=} delete_modal
 * @property {boolean=} disable_swiping
 * @property {boolean=} disable_hover_cards
 * @property {string=} disabled_account_id
 * @property {string} display_media
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
 * @property {boolean} trends_enabled
 * @property {boolean} single_user_mode
 * @property {string} source_url
 * @property {string} streaming_api_base_url
 * @property {boolean} timeline_preview
 * @property {string} title
 * @property {boolean} show_trends
 * @property {boolean} trends_as_landing_page
 * @property {boolean} use_blurhash
 * @property {boolean=} use_pending_items
 * @property {string} version
 * @property {string} sso_redirect
 */

/**
 * @typedef Role
 * @property {string} id
 * @property {string} name
 * @property {string} permissions
 * @property {string} color
 * @property {boolean} highlighted
 */

/**
 * @typedef InitialState
 * @property {Record<string, import("./api_types/accounts").ApiAccountJSON>} accounts
 * @property {InitialStateLanguage[]} languages
 * @property {boolean=} critical_updates_pending
 * @property {InitialStateMeta} meta
 * @property {Role?} role
 */

const element = document.getElementById('initial-state');
/** @type {InitialState | undefined} */
const initialState = element?.textContent && JSON.parse(element.textContent);

/** @type {string} */
const initialPath = document.querySelector("head meta[name=initialPath]")?.getAttribute("content") ?? '';
/** @type {boolean} */
export const hasMultiColumnPath = initialPath === '/'
  || initialPath === '/getting-started'
  || initialPath === '/home'
  || initialPath.startsWith('/deck');

/**
 * @template {keyof InitialStateMeta} K
 * @param {K} prop
 * @returns {InitialStateMeta[K] | undefined}
 */
const getMeta = (prop) => initialState?.meta && initialState.meta[prop];

export const activityApiEnabled = getMeta('activity_api_enabled');
export const autoPlayGif = getMeta('auto_play_gif');
export const boostModal = getMeta('boost_modal');
export const deleteModal = getMeta('delete_modal');
export const disableSwiping = getMeta('disable_swiping');
export const disableHoverCards = getMeta('disable_hover_cards');
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
export const trendsEnabled = getMeta('trends_enabled');
export const showTrends = getMeta('show_trends');
export const singleUserMode = getMeta('single_user_mode');
export const source_url = getMeta('source_url');
export const timelinePreview = getMeta('timeline_preview');
export const title = getMeta('title');
export const trendsAsLanding = getMeta('trends_as_landing_page');
export const useBlurhash = getMeta('use_blurhash');
export const usePendingItems = getMeta('use_pending_items');
export const version = getMeta('version');
export const languages = initialState?.languages;
export const criticalUpdatesPending = initialState?.critical_updates_pending;
// @ts-expect-error
export const statusPageUrl = getMeta('status_page_url');
export const sso_redirect = getMeta('sso_redirect');

/**
 * @returns {string | undefined}
 */
export function getAccessToken() {
  return getMeta('access_token');
}

export default initialState;
