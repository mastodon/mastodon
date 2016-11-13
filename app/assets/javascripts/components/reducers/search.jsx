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

const normalizeSuggestions = (state, value, accounts) => {
  let newSuggestions = [
    {
      title: 'Account',
      items: accounts.map(item => ({
        type: 'account',
        id: item.id,
        value: item.acct
      }))
    }
  ];

  if (value.indexOf('@') === -1) {
    newSuggestions.push({
      title: 'Hashtag',
      items: [
        {
          type: 'hashtag',
          id: value,
          value: `#${value}`
        }
      ]
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
      return normalizeSuggestions(state, action.value, action.accounts);
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
