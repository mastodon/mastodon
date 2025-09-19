import { autoPlayGif } from '@/mastodon/initial_state';

const PARENT_MAX_DEPTH = 10;

export function handleAnimateGif(event: MouseEvent) {
  // We already check this in ui/index.jsx, but just to be sure.
  if (autoPlayGif) {
    return;
  }

  const { target, type } = event;
  const animate = type === 'mouseover'; // Mouse over = animate, mouse out = don't animate.

  if (target instanceof HTMLImageElement) {
    setAnimateGif(target, animate);
  } else if (!(target instanceof HTMLElement) || target === document.body) {
    return;
  }

  let parent: HTMLElement | null = null;
  let iter = 0;

  if (target.classList.contains('animate-parent')) {
    parent = target;
  } else {
    // Iterate up to PARENT_MAX_DEPTH levels up the DOM tree to find a parent with the class 'animate-parent'.
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

  // Affect all animated children within the parent.
  if (parent) {
    const animatedChildren =
      parent.querySelectorAll<HTMLImageElement>('img.custom-emoji');
    for (const child of animatedChildren) {
      setAnimateGif(child, animate);
    }
  }
}

function setAnimateGif(image: HTMLImageElement, animate: boolean) {
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
