export const SET_PLAYING = 'AUDIO_PLAYER.SET_PLAYING';
export const SET_PAUSED = 'AUDIO_PLAYER.SET_PAUSED';
export const VOLUME_UP = 'AUDIO_PLAYER.VOLUME_UP';
export const VOLUME_DOWN = 'AUDIO_PLAYER.VOLUME_DOWN';
export const MUTE = 'AUDIO_PLAYER.MUTE';
export const UNMUTE = 'AUDIO_PLAYER.UNMUTE';
export const SET_ERROR = 'AUDIO_PLAYER.SET_ERROR';
export const SET_LOADING = 'AUDIO_PLAYER.SET_LOADING';
export const FINISHED_LOADING = 'AUDIO_PLAYER.FINISHED_LOADING';

export function setPlaying() {
  return {
    type: SET_PLAYING,
  };
}

export function setPaused() {
  return {
    type: SET_PAUSED,
  };
};

export function volumeUp() {
  return {
    type: VOLUME_UP,
  };
}

export function volumeDown() {
  return {
    type: VOLUME_DOWN,
  };
}

export function mute() {
  return {
    type: MUTE,
  };
}

export function unmute() {
  return {
    type: UNMUTE,
  };
}

export function setError(error) {
  return {
    type: SET_ERROR,
    payload: error,
  };
}

export function setLoading() {
  return {
    type: SET_LOADING,
  };
}

export function finishedLoading() {
  return {
    type: FINISHED_LOADING,
  };
}
