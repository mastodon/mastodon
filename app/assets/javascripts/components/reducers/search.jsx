import {
  SEARCH_CHANGE,
  SEARCH_SUGGESTIONS_READY,
  SEARCH_RESET
} from '../actions/search';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  value: '',
  loaded_value: '',
  suggestions: []
});

const normalizeSuggestions = (state, value, accounts, hashtags, statuses) => {
  let newSuggestions = [];

  if (accounts.length > 0) {
    newSuggestions.push({
      title: 'account',
      items: accounts.map(item => ({
        type: 'account',
        id: item.id,
        value: item.acct
      }))
    });
  }

  if (value.indexOf('@') === -1 && value.indexOf(' ') === -1 || hashtags.length > 0) {
    let hashtagItems = hashtags.map(item => ({
      type: 'hashtag',
      id: item,
      value: `#${item}`
    }));

    if (value.indexOf('@') === -1 && value.indexOf(' ') === -1 && hashtags.indexOf(value) === -1) {
      hashtagItems.unshift({
        type: 'hashtag',
        id: value,
        value: `#${value}`
      });
    }

    newSuggestions.push({
      title: 'hashtag',
      items: hashtagItems
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
  case SEARCH_SUGGESTIONS_READY:
    return normalizeSuggestions(state, action.value, action.accounts, action.hashtags, action.statuses);
  case SEARCH_RESET:
    return state.withMutations(map => {
      map.set('suggestions', []);
      map.set('value', '');
      map.set('loaded_value', '');
    });
  default:
    return state;
  }
};
