import { combineReducers } from 'redux-immutable';
import dropdown_menu from './dropdown_menu';
import timelines from './timelines';
import meta from './meta';
import alerts from './alerts';
import { loadingBarReducer } from 'react-redux-loading-bar';
import modal from './modal';
import user_lists from './user_lists';
import domain_lists from './domain_lists';
import accounts from './accounts';
import accounts_counters from './accounts_counters';
import statuses from './statuses';
import relationships from './relationships';
import settings from './settings';
import local_settings from './local_settings';
import push_notifications from './push_notifications';
import status_lists from './status_lists';
import mutes from './mutes';
import blocks from './blocks';
import reports from './reports';
import contexts from './contexts';
import compose from './compose';
import search from './search';
import media_attachments from './media_attachments';
import notifications from './notifications';
import height_cache from './height_cache';
import custom_emojis from './custom_emojis';
import lists from './lists';
import listEditor from './list_editor';
import listAdder from './list_adder';
import filters from './filters';
import conversations from './conversations';
import suggestions from './suggestions';
import pinnedAccountsEditor from './pinned_accounts_editor';
import polls from './polls';
import identity_proofs from './identity_proofs';
import trends from './trends';
import announcements from './announcements';
import markers from './markers';
import account_notes from './account_notes';
import picture_in_picture from './picture_in_picture';

const reducers = {
  announcements,
  dropdown_menu,
  timelines,
  meta,
  alerts,
  loadingBar: loadingBarReducer,
  modal,
  user_lists,
  domain_lists,
  status_lists,
  accounts,
  accounts_counters,
  statuses,
  relationships,
  settings,
  local_settings,
  push_notifications,
  mutes,
  blocks,
  reports,
  contexts,
  compose,
  search,
  media_attachments,
  notifications,
  height_cache,
  custom_emojis,
  identity_proofs,
  lists,
  listEditor,
  listAdder,
  filters,
  conversations,
  suggestions,
  pinnedAccountsEditor,
  polls,
  trends,
  markers,
  account_notes,
  picture_in_picture,
};

export default combineReducers(reducers);
