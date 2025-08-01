import type { MouseEventHandler } from 'react';

import { autoPlayGif } from '@/mastodon/initial_state';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

export const handleAnimateEnter: MouseEventHandler = ({ currentTarget }) => {
  if (autoPlayGif || isModernEmojiEnabled()) {
    return;
  }

  currentTarget
    .querySelectorAll<HTMLImageElement>('img.custom-emoji')
    .forEach((emoji) => {
      toggleAnimatedGif(emoji, true);
    });
};

export const handleAnimateLeave: MouseEventHandler = ({ currentTarget }) => {
  if (autoPlayGif || isModernEmojiEnabled()) {
    return;
  }

  currentTarget
    .querySelectorAll<HTMLImageElement>('img.custom-emoji')
    .forEach((emoji) => {
      toggleAnimatedGif(emoji, false);
    });
};

const PARENT_MAX_DEPTH = 10;

export function handleAnimateGif(event: MouseEvent) {
  const { target, type } = event;
  const animate = type === 'mouseover';
  if (target instanceof HTMLImageElement) {
    toggleAnimatedGif(target, animate);
  } else if (!(target instanceof HTMLElement) || target === document.body) {
    return;
  }
  let parent: HTMLElement | null = null;
  let iter = 0;
  if (target.classList.contains('animate-parent')) {
    parent = target;
  } else {
    let current: HTMLElement | null = target;
    while (current) {
      if (iter >= PARENT_MAX_DEPTH) {
        return; // We can just exit right now.
      }
      current = current.parentElement;
      if (current?.classList.contains('animate-parent')) {
        parent = current;
        break;
      }
      iter++;
    }
  }

  if (parent) {
    const animatedChildren =
      parent.querySelectorAll<HTMLImageElement>('img.custom-emoji');
    for (const child of animatedChildren) {
      toggleAnimatedGif(child, animate);
    }
  }
}

function toggleAnimatedGif(image: HTMLImageElement, animate: boolean) {
  const { classList, dataset } = image;
  if (
    !classList.contains('custom-emoji') ||
    !dataset.static ||
    !dataset.original
  ) {
    return;
  }
  image.src = animate ? dataset.original : dataset.static;
}
