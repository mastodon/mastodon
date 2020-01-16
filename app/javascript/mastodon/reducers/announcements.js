import {
  ANNOUNCEMENTS_FETCH_REQUEST,
  ANNOUNCEMENTS_FETCH_SUCCESS,
  ANNOUNCEMENTS_FETCH_FAIL,
  ANNOUNCEMENTS_UPDATE,
  ANNOUNCEMENTS_DISMISS,
  ANNOUNCEMENTS_REACTION_UPDATE,
  ANNOUNCEMENTS_REACTION_ADD_REQUEST,
  ANNOUNCEMENTS_REACTION_ADD_FAIL,
  ANNOUNCEMENTS_REACTION_REMOVE_REQUEST,
  ANNOUNCEMENTS_REACTION_REMOVE_FAIL,
} from '../actions/announcements';
import { Map as ImmutableMap, List as ImmutableList, fromJS } from 'immutable';

const initialState = ImmutableMap({
  items: ImmutableList(),
  isLoading: false,
});

const updateReaction = (state, id, name, updater) => state.update('items', list => list.map(announcement => {
  if (announcement.get('id') === id) {
    return announcement.update('reactions', reactions => {
      if (reactions.find(reaction => reaction.get('name') === name)) {
        return reactions.map(reaction => {
          if (reaction.get('name') === name) {
            return updater(reaction);
          }

          return reaction;
        });
      }

      return reactions.push(updater(fromJS({ name, count: 0 })));
    });
  }

  return announcement;
}));

const updateReactionCount = (state, reaction) => updateReaction(state, reaction.announcement_id, reaction.name, x => x.set('count', reaction.count));

const addReaction = (state, id, name) => updateReaction(state, id, name, x => x.set('me', true).update('count', y => y + 1));

const removeReaction = (state, id, name) => updateReaction(state, id, name, x => x.set('me', false).update('count', y => y - 1));

export default function announcementsReducer(state = initialState, action) {
  switch(action.type) {
  case ANNOUNCEMENTS_FETCH_REQUEST:
    return state.set('isLoading', true);
  case ANNOUNCEMENTS_FETCH_SUCCESS:
    return state.withMutations(map => {
      map.set('items', fromJS(action.announcements));
      map.set('isLoading', false);
    });
  case ANNOUNCEMENTS_FETCH_FAIL:
    return state.set('isLoading', false);
  case ANNOUNCEMENTS_UPDATE:
    return state.update('items', list => list.unshift(fromJS(action.announcement)).sortBy(announcement => announcement.get('starts_at')));
  case ANNOUNCEMENTS_DISMISS:
    return state.update('items', list => list.filterNot(announcement => announcement.get('id') === action.id));
  case ANNOUNCEMENTS_REACTION_UPDATE:
    return updateReactionCount(state, action.reaction);
  case ANNOUNCEMENTS_REACTION_ADD_REQUEST:
  case ANNOUNCEMENTS_REACTION_REMOVE_FAIL:
    return addReaction(state, action.id, action.name);
  case ANNOUNCEMENTS_REACTION_REMOVE_REQUEST:
  case ANNOUNCEMENTS_REACTION_ADD_FAIL:
    return removeReaction(state, action.id, action.name);
  default:
    return state;
  }
};
