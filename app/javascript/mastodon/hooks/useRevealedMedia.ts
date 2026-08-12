import { useState } from 'react';

import { displayMedia } from 'mastodon/initial_state';

interface RevealedMediaProps {
  visible?: boolean;
  sensitive?: boolean;
}

function getRevealedState({ visible, sensitive }: RevealedMediaProps) {
  if (typeof visible !== 'undefined') {
    return visible;
  } else {
    return (
      displayMedia === 'show_all' || (displayMedia !== 'hide_all' && !sensitive)
    );
  }
}

export function useRevealedMedia({ visible, sensitive }: RevealedMediaProps) {
  const [revealed, setRevealed] = useState(() =>
    getRevealedState({ visible, sensitive }),
  );

  // Update `revealed` state when `sensitive` or `visible` props change
  const [previous, setPrevious] = useState({ visible, sensitive });
  if (sensitive !== previous.sensitive || visible !== previous.visible) {
    setRevealed(getRevealedState({ visible, sensitive }));
    setPrevious({ visible, sensitive });
  }

  return [revealed, setRevealed] as const;
}
