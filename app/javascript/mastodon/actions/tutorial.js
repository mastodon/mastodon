export const TUTORIAL_OPEN = 'TUTORIAL_OPEN';
export const TUTORIAL_CLOSE = 'TUTORIAL_CLOSE';

export function openTutorial() {
  return {
    type: TUTORIAL_OPEN,
  };
};

export function closeTutorial() {
  return {
    type: TUTORIAL_CLOSE,
  };
};
