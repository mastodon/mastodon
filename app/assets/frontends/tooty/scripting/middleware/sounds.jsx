const play = audio => {
  if (!audio.paused) {
    audio.pause();
    audio.fastSeek(0);
  }

  audio.play();
};

export default function soundsMiddleware() {
  const soundCache = {
    boop: new Audio(['/sounds/boop.mp3'])
  };

  return ({ dispatch }) => next => (action) => {
    if (action.meta && action.meta.sound && soundCache[action.meta.sound]) {
      play(soundCache[action.meta.sound]);
    }

    return next(action);
  };
};
