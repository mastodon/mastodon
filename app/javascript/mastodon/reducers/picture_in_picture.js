import { PICTURE_IN_PICTURE_DEPLOY, PICTURE_IN_PICTURE_REMOVE } from 'mastodon/actions/picture_in_picture';
import { TIMELINE_DELETE } from '../actions/timelines';

const initialState = {
  statusId: null,
  accountId: null,
  type: null,
  src: null,
  muted: false,
  volume: 0,
  currentTime: 0,
};

export default function pictureInPicture(state = initialState, action) {
  switch(action.type) {
  case PICTURE_IN_PICTURE_DEPLOY:
    return { statusId: action.statusId, accountId: action.accountId, type: action.playerType, ...action.props };
  case PICTURE_IN_PICTURE_REMOVE:
    return { ...initialState };
  case TIMELINE_DELETE:
    return (state.statusId === action.id) ? { ...initialState } : state;
  default:
    return state;
  }
}
