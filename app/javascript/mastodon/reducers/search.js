import {
  SEARCH_CHANGE,
  SEARCH_CLEAR,
  SEARCH_FETCH_SUCCESS,
  SEARCH_SHOW,
} from '../actions/search';
import { COMPOSE_MENTION, COMPOSE_REPLY } from '../actions/compose';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  value: '',
  submitted: false,
  hidden: false,
  results: Immutable.Map(),
});

const normalizeSuggestions = (state, value, accounts, hashtags, statuses) => {
  let newSuggestions = [];

  if (accounts.length > 0) {
    newSuggestions.push({
      title: 'account',
      items: accounts.map(item => ({
        type: 'account',
        id: item.id,
        value: item.acct,
      })),
    });
  }

  if (value.indexOf('@') === -1 && value.indexOf(' ') === -1 || hashtags.length > 0) {
    let hashtagItems = hashtags.map(item => ({
      type: 'hashtag',
      id: item,
      value: `#${item}`,
    }));

    if (value.indexOf('@') === -1 && value.indexOf(' ') === -1 && !value.startsWith('http://') && !value.startsWith('https://') && hashtags.indexOf(value) === -1) {
      hashtagItems.unshift({
        type: 'hashtag',
        id: value,
        value: `#${value}`,
      });
    }

    if (hashtagItems.length > 0) {
      newSuggestions.push({
        title: 'hashtag',
        items: hashtagItems,
      });
    }
  }

  if (statuses.length > 0) {
    newSuggestions.push({
      title: 'status',
      items: statuses.map(item => ({
        type: 'status',
        id: item.id,
        value: item.id,
      })),
    });
  }

  return state.withMutations(map => {
    map.set('suggestions', newSuggestions);
    map.set('loaded_value', value);
  });
};

export default function search(state = initialState, action) {
  switch(action.type) {
  case SEARCH_CHANGE:
    return state.set('value', action.value);
  case SEARCH_CLEAR:
    return state.withMutations(map => {
      map.set('value', '');
      map.set('results', Immutable.Map());
      map.set('submitted', false);
      map.set('hidden', false);
    });
  case SEARCH_SHOW:
    return state.set('hidden', false);
  case COMPOSE_REPLY:
  case COMPOSE_MENTION:
    return state.set('hidden', true);
  case SEARCH_FETCH_SUCCESS:
    return state.set('results', Immutable.Map({
      accounts: Immutable.List(action.results.accounts.map(item => item.id)),
      statuses: Immutable.List(action.results.statuses.map(item => item.id)),
      hashtags: Immutable.List(action.results.hashtags),
    })).set('submitted', true);
  default:
    return state;
  }
};
