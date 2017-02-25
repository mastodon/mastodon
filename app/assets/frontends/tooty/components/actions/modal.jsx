export const MEDIA_OPEN  = 'MEDIA_OPEN';
export const MODAL_CLOSE = 'MODAL_CLOSE';

export const MODAL_INDEX_DECREASE = 'MODAL_INDEX_DECREASE';
export const MODAL_INDEX_INCREASE = 'MODAL_INDEX_INCREASE';

export function openMedia(media, index) {
  return {
    type: MEDIA_OPEN,
    media,
    index
  };
};

export function closeModal() {
  return {
    type: MODAL_CLOSE
  };
};

export function decreaseIndexInModal() {
  return {
    type: MODAL_INDEX_DECREASE
  };
};

export function increaseIndexInModal() {
  return {
    type: MODAL_INDEX_INCREASE
  };
};
