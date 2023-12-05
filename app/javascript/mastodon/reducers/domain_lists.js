import { Map as ImmutableMap, OrderedSet as ImmutableOrderedSet } from 'immutable';

import {
  DOMAIN_BLOCKS_FETCH_SUCCESS,
  DOMAIN_BLOCKS_EXPAND_SUCCESS,
  unblockDomainSuccess
} from '../actions/domain_blocks';

const initialState = ImmutableMap({
  blocks: ImmutableMap({
    items: ImmutableOrderedSet(),
  }),
});

export default function domainLists(state = initialState, action) {
  switch(action.type) {
  case DOMAIN_BLOCKS_FETCH_SUCCESS:
    return state.setIn(['blocks', 'items'], ImmutableOrderedSet(action.domains)).setIn(['blocks', 'next'], action.next);
  case DOMAIN_BLOCKS_EXPAND_SUCCESS:
    return state.updateIn(['blocks', 'items'], set => set.union(action.domains)).setIn(['blocks', 'next'], action.next);
  case unblockDomainSuccess.type:
    return state.updateIn(['blocks', 'items'], set => set.delete(action.payload.domain));
  default:
    return state;
  }
}
