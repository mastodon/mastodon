import type { Reducer } from '@reduxjs/toolkit';

import {
  deployPictureInPictureAction,
  removePictureInPicture,
} from 'mastodon/actions/picture_in_picture';

import { TIMELINE_DELETE } from '../actions/timelines';

export interface PIPMediaProps {
  src: string;
  muted: boolean;
  volume: number;
  currentTime: number;
  poster: string;
  backgroundColor: string;
  foregroundColor: string;
  accentColor: string;
}

interface PIPStateWithValue extends Partial<PIPMediaProps> {
  statusId: string;
  accountId: string;
  type: 'audio' | 'video';
}

interface PIPStateEmpty extends Partial<PIPMediaProps> {
  type: null;
}

type PIPState = PIPStateWithValue | PIPStateEmpty;

const initialState = {
  type: null,
  muted: false,
  volume: 0,
  currentTime: 0,
};

export const pictureInPictureReducer: Reducer<PIPState> = (
  state = initialState,
  action,
) => {
  if (deployPictureInPictureAction.match(action))
    return {
      statusId: action.payload.statusId,
      accountId: action.payload.accountId,
      type: action.payload.playerType,
      ...action.payload.props,
    };
  else if (removePictureInPicture.match(action)) return initialState;
  else if (action.type === TIMELINE_DELETE)
    if (state.type && state.statusId === action.id) return initialState;

  return state;
};
