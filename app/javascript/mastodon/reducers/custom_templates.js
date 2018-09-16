import { List as ImmutableList, fromJS as ConvertToImmutable } from 'immutable';
import { CUSTOM_TEMPLATES_FETCH_SUCCESS } from '../actions/custom_templates';

const initialState = ImmutableList([]);

export default function custom_templates(state = initialState, action) {
  if (action.type === CUSTOM_TEMPLATES_FETCH_SUCCESS) {
    state = ConvertToImmutable(action.custom_templates);
  }

  return state;
};
