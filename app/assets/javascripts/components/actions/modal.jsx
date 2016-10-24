export const MEDIA_OPEN  = 'MEDIA_OPEN';
export const MODAL_CLOSE = 'MODAL_CLOSE';

export function openMedia(url) {
  return {
    type: MEDIA_OPEN,
    url: url
  };
};

export function closeModal() {
  return {
    type: MODAL_CLOSE
  };
};
