import { TUTORIAL_OPEN, TUTORIAL_CLOSE } from '../actions/tutorial';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  visible: false,
});

export default function tutorial(state = initialState, action) {
  switch (action.type) {
  case TUTORIAL_OPEN:
    return state.set('visible', true);
  case TUTORIAL_CLOSE:
    return initialState;
  default:
    return state;
  }
};
