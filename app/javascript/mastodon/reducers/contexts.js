import {
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_MUTE_SUCCESS,
} from '../actions/accounts';
import { CONTEXT_FETCH_SUCCESS } from '../actions/statuses';
import { TIMELINE_DELETE, TIMELINE_UPDATE } from '../actions/timelines';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import { compareId } from '../compare_id';

const initialState = ImmutableMap({
  inReplyTos: ImmutableMap(),
  replies: ImmutableMap(),
});

const normalizeContext = (immutableState, id, ancestors, descendants) => immutableState.withMutations(state => {
  state.update('inReplyTos', immutableAncestors => immutableAncestors.withMutations(inReplyTos => {
    state.update('replies', immutableDescendants => immutableDescendants.withMutations(replies => {
      function addReply({ id, in_reply_to_id }) {
        if (in_reply_to_id && !inReplyTos.has(id)) {

          replies.update(in_reply_to_id, ImmutableList(), siblings => {
            const index = siblings.findLastIndex(sibling => compareId(sibling, id) < 0);
            return siblings.insert(index + 1, id);
          });

          inReplyTos.set(id, in_reply_to_id);
        }
      }

      // We know in_reply_to_id of statuses but `id` itself.
      // So we assume that the status of the id replies to last ancestors.

      ancestors.forEach(addReply);

      if (ancestors[0]) {
        addReply({ id, in_reply_to_id: ancestors[ancestors.length - 1].id });
      }

      descendants.forEach(addReply);
    }));
  }));
});

const deleteFromContexts = (immutableState, ids) => immutableState.withMutations(state => {
  state.update('inReplyTos', immutableAncestors => immutableAncestors.withMutations(inReplyTos => {
    state.update('replies', immutableDescendants => immutableDescendants.withMutations(replies => {
      ids.forEach(id => {
        const inReplyToIdOfId = inReplyTos.get(id);
        const repliesOfId = replies.get(id);
        const siblings = replies.get(inReplyToIdOfId);

        if (siblings) {
          replies.set(inReplyToIdOfId, siblings.filterNot(sibling => sibling === id));
        }


        if (repliesOfId) {
          repliesOfId.forEach(reply => inReplyTos.delete(reply));
        }

        inReplyTos.delete(id);
        replies.delete(id);
      });
    }));
  }));
});

const filterContexts = (state, relationship, statuses) => {
  const ownedStatusIds = statuses
    .filter(status => status.get('account') === relationship.id)
    .map(status => status.get('id'));

  return deleteFromContexts(state, ownedStatusIds);
};

const updateContext = (state, status) => {
  if (status.in_reply_to_id) {
    return state.withMutations(mutable => {
      const replies = mutable.getIn(['replies', status.in_reply_to_id], ImmutableList());

      mutable.setIn(['inReplyTos', status.id], status.in_reply_to_id);

      if (!replies.includes(status.id)) {
        mutable.setIn(['replies', status.in_reply_to_id], replies.push(status.id));
      }
    });
  }

  return state;
};

export default function replies(state = initialState, action) {
  switch(action.type) {
  case ACCOUNT_BLOCK_SUCCESS:
  case ACCOUNT_MUTE_SUCCESS:
    return filterContexts(state, action.relationship, action.statuses);
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
