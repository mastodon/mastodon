export const ACCESS_TOKEN_SET = 'ACCESS_TOKEN_SET';

export function setAccessToken(token) {
  return {
    type: ACCESS_TOKEN_SET,
    token: token
  };
};
