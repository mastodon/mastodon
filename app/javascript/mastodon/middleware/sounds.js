const createAudio = sources => {
  const audio = new Audio();
  sources.forEach(({ type, src }) => {
    const source = document.createElement('source');
    source.type = type;
    source.src = src;
    audio.appendChild(source);
  });
  return audio;
};

const play = audio => {
  if (!audio.paused) {
    audio.pause();
    audio.fastSeek(0);
  }

  audio.play();
};

export default function soundsMiddleware() {
  const soundCache = {
    boop: createAudio([
      {
        src: '/sounds/boop.ogg',
        type: 'audio/ogg',
      },
      {
        src: '/sounds/boop.mp3',
        type: 'audio/mpeg',
      },
    ]),
  };

  return () => next => action => {
    if (action.meta && action.meta.sound && soundCache[action.meta.sound]) {
      play(soundCache[action.meta.sound]);
    }

    return next(action);
  };
};
