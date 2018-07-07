import * as actions from '../actions/audio_player';

const initialState = {
  isPlaying: false,
  isLoading: true,
  volume: 0.6,
  muted: false,
  error: { code: -1 },
};

export default function audioPlayer(state = initialState, action) {
  switch (action.type) {
  case actions.SET_PLAYING: {
    return {
      ...state,
      isPlaying: true,
    };
  }
  case actions.SET_PAUSED: {
    return {
      ...state,
      isPlaying: false,
    };
  }
  case actions.VOLUME_UP: {
    return {
      ...state,
      volume: state.volume > 0.9 ? state.volume : state.volume + 0.1,
    };
  }
  case actions.VOLUME_DOWN: {
    return {
      ...state,
      volume: state.volume < 0.1 ? state.volume : state.volume - 0.1,
    };
  }
  case actions.MUTE: {
    return {
      ...state,
      muted: true,
    };
  }
  case actions.UNMUTE: {
    return {
      ...state,
      muted: false,
    };
  }
  case actions.SET_ERROR: {
    return {
      ...state,
      error: action.payload,
    };
  }
  case actions.SET_LOADING: {
    return {
      ...state,
      isLoading: true,
    };
  }
  case actions.FINISHED_LOADING: {
    return {
      ...state,
      isLoading: false,
    };
  }
  default: {
    return state;
  }
  }
}
