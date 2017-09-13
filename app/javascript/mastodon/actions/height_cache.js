export const HEIGHT_CACHE_SET = 'HEIGHT_CACHE_SET';
export const HEIGHT_CACHE_CLEAR = 'HEIGHT_CACHE_CLEAR';

export function setHeight (key, id, height) {
  return {
    type: HEIGHT_CACHE_SET,
    key,
    id,
    height,
  };
};

export function clearHeight () {
  return {
    type: HEIGHT_CACHE_CLEAR,
  };
};
