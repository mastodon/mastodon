import { loadingBarReducer } from 'react-redux-loading-bar';
import { combineReducers } from 'redux-immutable';

import accounts from './accounts';
import accounts_counters from './accounts_counters';
import accounts_map from './accounts_map';
import alerts from './alerts';
import announcements from './announcements';
import blocks from './blocks';
import boosts from './boosts';
import compose from './compose';
import contexts from './contexts';
import conversations from './conversations';
import custom_emojis from './custom_emojis';
import domain_lists from './domain_lists';
import dropdown_menu from './dropdown_menu';
import filters from './filters';
import followed_tags from './followed_tags';
import height_cache from './height_cache';
import history from './history';
import listAdder from './list_adder';
import listEditor from './list_editor';
import lists from './lists';
import markers from './markers';
import media_attachments from './media_attachments';
import meta from './meta';
import { missedUpdatesReducer } from './missed_updates';
import { modalReducer } from './modal';
import mutes from './mutes';
import notifications from './notifications';
import picture_in_picture from './picture_in_picture';
import polls from './polls';
import push_notifications from './push_notifications';
import relationships from './relationships';
import search from './search';
import server from './server';
import settings from './settings';
import status_lists from './status_lists';
import statuses from './statuses';
import suggestions from './suggestions';
import tags from './tags';
import timelines from './timelines';
import trends from './trends';
import user_lists from './user_lists';

const reducers = {
  announcements,
  dropdown_menu,
  timelines,
  meta,
  alerts,
  loadingBar: loadingBarReducer,
  modal: modalReducer,
  user_lists,
  domain_lists,
  status_lists,
  accounts,
  accounts_counters,
  accounts_map,
  statuses,
  relationships,
  settings,
  push_notifications,
  mutes,
  blocks,
  boosts,
  server,
  contexts,
  compose,
  search,
  media_attachments,
  notifications,
  height_cache,
  custom_emojis,
  lists,
  listEditor,
  listAdder,
  filters,
  conversations,
  suggestions,
  polls,
  trends,
  missed_updates: missedUpdatesReducer,
  markers,
  picture_in_picture,
  history,
  tags,
  followed_tags,
};

const rootReducer = combineReducers(reducers);

export { rootReducer };
