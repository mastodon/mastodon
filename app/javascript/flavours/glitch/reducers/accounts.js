import {
  ACCOUNT_FETCH_SUCCESS,
  FOLLOWERS_FETCH_SUCCESS,
  FOLLOWERS_EXPAND_SUCCESS,
  FOLLOWING_FETCH_SUCCESS,
  FOLLOWING_EXPAND_SUCCESS,
  FOLLOW_REQUESTS_FETCH_SUCCESS,
  FOLLOW_REQUESTS_EXPAND_SUCCESS,
  PINNED_ACCOUNTS_FETCH_SUCCESS,
  PINNED_ACCOUNTS_EDITOR_SUGGESTIONS_READY,
} from 'flavours/glitch/actions/accounts';
import {
  BLOCKS_FETCH_SUCCESS,
  BLOCKS_EXPAND_SUCCESS,
} from 'flavours/glitch/actions/blocks';
import {
  MUTES_FETCH_SUCCESS,
  MUTES_EXPAND_SUCCESS,
} from 'flavours/glitch/actions/mutes';
import { COMPOSE_SUGGESTIONS_READY } from 'flavours/glitch/actions/compose';
import {
  REBLOG_SUCCESS,
  UNREBLOG_SUCCESS,
  FAVOURITE_SUCCESS,
  UNFAVOURITE_SUCCESS,
  BOOKMARK_SUCCESS,
  UNBOOKMARK_SUCCESS,
  REBLOGS_FETCH_SUCCESS,
  FAVOURITES_FETCH_SUCCESS,
} from 'flavours/glitch/actions/interactions';
import {
  TIMELINE_UPDATE,
  TIMELINE_EXPAND_SUCCESS,
} from 'flavours/glitch/actions/timelines';
import {
  STATUS_FETCH_SUCCESS,
  CONTEXT_FETCH_SUCCESS,
} from 'flavours/glitch/actions/statuses';
import { SEARCH_FETCH_SUCCESS } from 'flavours/glitch/actions/search';
import {
  NOTIFICATIONS_UPDATE,
  NOTIFICATIONS_EXPAND_SUCCESS,
} from 'flavours/glitch/actions/notifications';
import {
  FAVOURITED_STATUSES_FETCH_SUCCESS,
  FAVOURITED_STATUSES_EXPAND_SUCCESS,
} from 'flavours/glitch/actions/favourites';
import {
  BOOKMARKED_STATUSES_FETCH_SUCCESS,
  BOOKMARKED_STATUSES_EXPAND_SUCCESS,
} from 'flavours/glitch/actions/bookmarks';
import {
  LIST_ACCOUNTS_FETCH_SUCCESS,
  LIST_EDITOR_SUGGESTIONS_READY,
} from 'flavours/glitch/actions/lists';
import { STORE_HYDRATE } from 'flavours/glitch/actions/store';
import emojify from 'flavours/glitch/util/emoji';
import { Map as ImmutableMap, fromJS } from 'immutable';
import escapeTextContentForBrowser from 'escape-html';
import { unescapeHTML } from 'flavours/glitch/util/html';

const makeEmojiMap = record => record.emojis.reduce((obj, emoji) => {
  obj[`:${emoji.shortcode}:`] = emoji;
  return obj;
}, {});

const normalizeAccount = (state, account) => {
  account = { ...account };

  delete account.followers_count;
  delete account.following_count;
  delete account.statuses_count;

  const emojiMap = makeEmojiMap(account);
  const displayName = account.display_name.trim().length === 0 ? account.username : account.display_name;
  account.display_name_html = emojify(escapeTextContentForBrowser(displayName), emojiMap);
  account.note_emojified = emojify(account.note, emojiMap);

  if (account.fields) {
    account.fields = account.fields.map(pair => ({
      ...pair,
      name_emojified: emojify(escapeTextContentForBrowser(pair.name)),
      value_emojified: emojify(pair.value, emojiMap),
      value_plain: unescapeHTML(pair.value),
    }));
  }

  if (account.moved) {
    state = normalizeAccount(state, account.moved);
    account.moved = account.moved.id;
  }

  return state.set(account.id, fromJS(account));
};

const normalizeAccounts = (state, accounts) => {
  accounts.forEach(account => {
    state = normalizeAccount(state, account);
  });

  return state;
};

const normalizeAccountFromStatus = (state, status) => {
  state = normalizeAccount(state, status.account);

  if (status.reblog && status.reblog.account) {
    state = normalizeAccount(state, status.reblog.account);
  }

  return state;
};

const normalizeAccountsFromStatuses = (state, statuses) => {
  statuses.forEach(status => {
    state = normalizeAccountFromStatus(state, status);
  });

  return state;
};

const initialState = ImmutableMap();

export default function accounts(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE:
    return normalizeAccounts(state, Object.values(action.state.get('accounts').toJS()));
  case ACCOUNT_FETCH_SUCCESS:
  case NOTIFICATIONS_UPDATE:
    return normalizeAccount(state, action.account);
  case FOLLOWERS_FETCH_SUCCESS:
  case FOLLOWERS_EXPAND_SUCCESS:
  case FOLLOWING_FETCH_SUCCESS:
  case FOLLOWING_EXPAND_SUCCESS:
  case REBLOGS_FETCH_SUCCESS:
  case FAVOURITES_FETCH_SUCCESS:
  case COMPOSE_SUGGESTIONS_READY:
  case FOLLOW_REQUESTS_FETCH_SUCCESS:
  case FOLLOW_REQUESTS_EXPAND_SUCCESS:
  case BLOCKS_FETCH_SUCCESS:
  case BLOCKS_EXPAND_SUCCESS:
  case MUTES_FETCH_SUCCESS:
  case MUTES_EXPAND_SUCCESS:
  case LIST_ACCOUNTS_FETCH_SUCCESS:
  case LIST_EDITOR_SUGGESTIONS_READY:
  case PINNED_ACCOUNTS_FETCH_SUCCESS:
  case PINNED_ACCOUNTS_EDITOR_SUGGESTIONS_READY:
    return action.accounts ? normalizeAccounts(state, action.accounts) : state;
  case NOTIFICATIONS_EXPAND_SUCCESS:
  case SEARCH_FETCH_SUCCESS:
    return normalizeAccountsFromStatuses(normalizeAccounts(state, action.accounts), action.statuses);
  case TIMELINE_EXPAND_SUCCESS:
  case CONTEXT_FETCH_SUCCESS:
  case FAVOURITED_STATUSES_FETCH_SUCCESS:
  case FAVOURITED_STATUSES_EXPAND_SUCCESS:
  case BOOKMARKED_STATUSES_FETCH_SUCCESS:
  case BOOKMARKED_STATUSES_EXPAND_SUCCESS:
    return normalizeAccountsFromStatuses(state, action.statuses);
  case REBLOG_SUCCESS:
  case FAVOURITE_SUCCESS:
  case UNREBLOG_SUCCESS:
  case UNFAVOURITE_SUCCESS:
  case BOOKMARK_SUCCESS:
  case UNBOOKMARK_SUCCESS:
    return normalizeAccountFromStatus(state, action.response);
  case TIMELINE_UPDATE:
  case STATUS_FETCH_SUCCESS:
    return normalizeAccountFromStatus(state, action.status);
  default:
    return state;
  }
};
