import { Map as ImmutableMap, List as ImmutableList } from 'immutable';

import {
  blockAccountSuccess,
  muteAccountSuccess,
} from '../actions/accounts';
import { CONTEXT_FETCH_SUCCESS } from '../actions/statuses';
import { TIMELINE_DELETE, TIMELINE_UPDATE } from '../actions/timelines';

const initialState = ImmutableMap();

const normalizeContext = (state, id, ancestors, descendants) => state.set(id, ImmutableMap({
  ancestors: ImmutableList(ancestors.map(x => x.id)),
  descendants: ImmutableList(descendants.map(x => x.id)),
}));

const deleteFromContexts = (state, deletedIds) => state.update(contexts =>
  contexts.map(context =>
    context.update(map => ImmutableMap({
      ancestors: map.get('ancestors').filterNot(id => deletedIds.includes(id)),
      descendants: map.get('descendants').filterNot(id => deletedIds.includes(id)),
    }))));

const filterContexts = (state, relationship, statuses) => {
  const ownedStatusIds = statuses
    .filter(status => status.get('account') === relationship.id)
    .map(status => status.get('id'));

  return deleteFromContexts(state, ownedStatusIds);
};

const updateContext = (state, status) => {
  const inReplyToId = status.in_reply_to_id;

  if (inReplyToId) {
    return state.update(contexts => contexts.map((context, rootStatusId) => {
      if (context.get('descendants').includes(status.id)) {
        return context;
      }

      if (rootStatusId === inReplyToId) {
        return context.update('descendants', list => list.push(status.id));
      }

      const ancestorIndex = context.get('descendants').indexOf(inReplyToId);

      if (ancestorIndex !== -1) {
        return context.update('descendants', list => list.insert(ancestorIndex + 1, status.id));
      }

      return context;
    }));
  }

  return state;
};

export default function replies(state = initialState, action) {
  switch(action.type) {
  case blockAccountSuccess.type:
  case muteAccountSuccess.type:
    return filterContexts(state, action.payload.relationship, action.payload.statuses);
  case CONTEXT_FETCH_SUCCESS:
    return normalizeContext(state, action.id, action.ancestors, action.descendants);
  case TIMELINE_DELETE:
    return deleteFromContexts(state, [action.id]);
  case TIMELINE_UPDATE:
    return updateContext(state, action.status);
  default:
    return state;
  }
}
