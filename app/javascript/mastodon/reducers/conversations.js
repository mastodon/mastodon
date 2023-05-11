import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import {
  CONVERSATIONS_MOUNT,
  CONVERSATIONS_UNMOUNT,
  CONVERSATIONS_FETCH_REQUEST,
  CONVERSATIONS_FETCH_SUCCESS,
  CONVERSATIONS_FETCH_FAIL,
  CONVERSATIONS_UPDATE,
  CONVERSATIONS_READ,
  CONVERSATIONS_DELETE_SUCCESS,
} from '../actions/conversations';
import { ACCOUNT_BLOCK_SUCCESS, ACCOUNT_MUTE_SUCCESS } from 'mastodon/actions/accounts';
import { DOMAIN_BLOCK_SUCCESS } from 'mastodon/actions/domain_blocks';
import { compareId } from '../compare_id';

const initialState = ImmutableMap({
  items: ImmutableList(),
  isLoading: false,
  hasMore: true,
  mounted: false,
});

const conversationToMap = item => ImmutableMap({
  id: item.id,
  unread: item.unread,
  accounts: ImmutableList(item.accounts.map(a => a.id)),
  last_status: item.last_status ? item.last_status.id : null,
});

const updateConversation = (state, item) => state.update('items', list => {
  const index   = list.findIndex(x => x.get('id') === item.id);
  const newItem = conversationToMap(item);

  if (index === -1) {
    return list.unshift(newItem);
  } else {
    return list.set(index, newItem);
  }
});

const expandNormalizedConversations = (state, conversations, next, isLoadingRecent) => {
  let items = ImmutableList(conversations.map(conversationToMap));

  return state.withMutations(mutable => {
    if (!items.isEmpty()) {
      mutable.update('items', list => {
        list = list.map(oldItem => {
          const newItemIndex = items.findIndex(x => x.get('id') === oldItem.get('id'));

          if (newItemIndex === -1) {
            return oldItem;
          }

          const newItem = items.get(newItemIndex);
          items = items.delete(newItemIndex);

          return newItem;
        });

        list = list.concat(items);

        return list.sortBy(x => x.get('last_status'), (a, b) => {
          if(a === null || b === null) {
            return -1;
          }

          return compareId(a, b) * -1;
        });
      });
    }

    if (!next && !isLoadingRecent) {
      mutable.set('hasMore', false);
    }

    mutable.set('isLoading', false);
  });
};

const filterConversations = (state, accountIds) => {
  return state.update('items', list => list.filterNot(item => item.get('accounts').some(accountId => accountIds.includes(accountId))));
};

export default function conversations(state = initialState, action) {
  switch (action.type) {
  case CONVERSATIONS_FETCH_REQUEST:
    return state.set('isLoading', true);
  case CONVERSATIONS_FETCH_FAIL:
    return state.set('isLoading', false);
  case CONVERSATIONS_FETCH_SUCCESS:
    return expandNormalizedConversations(state, action.conversations, action.next, action.isLoadingRecent);
  case CONVERSATIONS_UPDATE:
    return updateConversation(state, action.conversation);
  case CONVERSATIONS_MOUNT:
    return state.update('mounted', count => count + 1);
  case CONVERSATIONS_UNMOUNT:
    return state.update('mounted', count => count - 1);
  case CONVERSATIONS_READ:
    return state.update('items', list => list.map(item => {
      if (item.get('id') === action.id) {
        return item.set('unread', false);
      }

      return item;
    }));
  case ACCOUNT_BLOCK_SUCCESS:
  case ACCOUNT_MUTE_SUCCESS:
    return filterConversations(state, [action.relationship.id]);
  case DOMAIN_BLOCK_SUCCESS:
    return filterConversations(state, action.accounts);
  case CONVERSATIONS_DELETE_SUCCESS:
    return state.update('items', list => list.filterNot(item => item.get('id') === action.id));
  default:
    return state;
  }
}
