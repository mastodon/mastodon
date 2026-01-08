import type { ApiAnnualReportState } from './api/annual_report';
import type { ApiAccountJSON } from './api_types/accounts';

type InitialStateLanguage = [code: string, name: string, localName: string];

interface InitialStateMeta {
  access_token: string;
  advanced_layout?: boolean;
  auto_play_gif: boolean;
  activity_api_enabled: boolean;
  admin: string;
  boost_modal?: boolean;
  quick_boosting?: boolean;
  delete_modal?: boolean;
  missing_alt_text_modal?: boolean;
  disable_swiping?: boolean;
  disable_hover_cards?: boolean;
  disabled_account_id?: string;
  display_media: string;
  domain: string;
  expand_spoilers?: boolean;
  limited_federation_mode: boolean;
  locale: string;
  mascot: string | null;
  me?: string;
  moved_to_account_id?: string;
  owner?: string;
  profile_directory: boolean;
  registrations_open: boolean;
  reduce_motion: boolean;
  repository: string;
  search_enabled: boolean;
  trends_enabled: boolean;
  single_user_mode: boolean;
  source_url: string;
  streaming_api_base_url: string;
  local_live_feed_access: 'public' | 'authenticated' | 'disabled';
  remote_live_feed_access: 'public' | 'authenticated' | 'disabled';
  local_topic_feed_access: 'public' | 'authenticated';
  remote_topic_feed_access: 'public' | 'authenticated' | 'disabled';
  title: string;
  show_trends: boolean;
  landing_page: 'about' | 'trends' | 'local_feed';
  use_blurhash: boolean;
  use_pending_items?: boolean;
  version: string;
  sso_redirect: string;
  status_page_url: string;
  terms_of_service_enabled: boolean;
  emoji_style?: string;
  wrapstodon?: InitialWrapstodonState | null;
}

interface Role {
  id: string;
  name: string;
  permissions: string;
  color: string;
  highlighted: boolean;
}

interface InitialWrapstodonState {
  year: number;
  state: ApiAnnualReportState;
}

export interface InitialState {
  accounts: Record<string, ApiAccountJSON>;
  languages: InitialStateLanguage[];
  critical_updates_pending?: boolean;
  meta: InitialStateMeta;
  role?: Role;
  features: string[];
}

const element = document.getElementById('initial-state');
export const initialState: InitialState | undefined = element?.textContent
  ? (JSON.parse(element.textContent) as InitialState)
  : undefined;

const initialPath: string =
  document
    .querySelector('head meta[name=initialPath]')
    ?.getAttribute('content') ?? '';
export const hasMultiColumnPath: boolean =
  initialPath === '/' ||
  initialPath === '/getting-started' ||
  initialPath === '/home' ||
  initialPath.startsWith('/deck');

function getMeta<K extends keyof InitialStateMeta>(
  prop: K,
): InitialStateMeta[K] | undefined {
  return initialState?.meta[prop];
}

export const activityApiEnabled = getMeta('activity_api_enabled');
export const autoPlayGif = getMeta('auto_play_gif');
export const boostModal = getMeta('boost_modal');
export const quickBoosting = getMeta('quick_boosting');
export const deleteModal = getMeta('delete_modal');
export const missingAltTextModal = getMeta('missing_alt_text_modal');
export const disableSwiping = getMeta('disable_swiping');
export const disableHoverCards = getMeta('disable_hover_cards');
export const disabledAccountId = getMeta('disabled_account_id');
export const displayMedia = getMeta('display_media');
export const domain = getMeta('domain');
export const emojiStyle = getMeta('emoji_style') ?? 'auto';
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
export const localLiveFeedAccess = getMeta('local_live_feed_access');
export const remoteLiveFeedAccess = getMeta('remote_live_feed_access');
export const localTopicFeedAccess = getMeta('local_topic_feed_access');
export const remoteTopicFeedAccess = getMeta('remote_topic_feed_access');
export const title = getMeta('title');
export const landingPage = getMeta('landing_page');
export const useBlurhash = getMeta('use_blurhash');
export const usePendingItems = getMeta('use_pending_items');
export const version = getMeta('version');
export const criticalUpdatesPending = initialState?.critical_updates_pending;
export const statusPageUrl = getMeta('status_page_url');
export const sso_redirect = getMeta('sso_redirect');
export const termsOfServiceEnabled = getMeta('terms_of_service_enabled');
export const wrapstodon = getMeta('wrapstodon');

const displayNames =
  // Intl.DisplayNames can be undefined in old browsers
  // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition
  Intl.DisplayNames &&
  (new Intl.DisplayNames(getMeta('locale'), {
    type: 'language',
    fallback: 'none',
    languageDisplay: 'standard',
  }) as Intl.DisplayNames | undefined);

export const languages = initialState?.languages.map((lang) => {
  // zh-YUE is not a valid CLDR unicode_language_id
  return [
    lang[0],
    displayNames?.of(lang[0].replace('zh-YUE', 'yue')) ?? lang[1],
    lang[2],
  ];
});

export function getAccessToken(): string | undefined {
  return getMeta('access_token');
}
