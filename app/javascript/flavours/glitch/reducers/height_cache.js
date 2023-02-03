import { Map as ImmutableMap } from 'immutable';
import { HEIGHT_CACHE_SET, HEIGHT_CACHE_CLEAR } from 'flavours/glitch/actions/height_cache';

const initialState = ImmutableMap();

const setHeight = (state, key, id, height) => {
  return state.update(key, ImmutableMap(), map => map.set(id, height));
};

const clearHeights = () => {
  return ImmutableMap();
};

export default function statuses(state = initialState, action) {
  switch(action.type) {
  case HEIGHT_CACHE_SET:
    return setHeight(state, action.key, action.id, action.height);
  case HEIGHT_CACHE_CLEAR:
    return clearHeights();
  default:
    return state;
  }
}
