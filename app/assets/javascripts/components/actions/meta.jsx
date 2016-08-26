export const SET_ACCESS_TOKEN = 'SET_ACCESS_TOKEN';

export function setAccessToken(token) {
  return {
    type: SET_ACCESS_TOKEN,
    token: token
  };
}
