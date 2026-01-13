import type { Modifier, UsePopperState } from 'react-overlays/esm/usePopper';

export const matchWidth: Modifier<'sameWidth', UsePopperState> = {
  name: 'sameWidth',
  enabled: true,
  phase: 'beforeWrite',
  requires: ['computeStyles'],
  fn: ({ state }) => {
    if (state.styles.popper) {
      state.styles.popper.width = `${state.rects.reference.width}px`;
    }
  },
  effect: ({ state }) => {
    const reference = state.elements.reference as HTMLElement;
    state.elements.popper.style.width = `${reference.offsetWidth}px`;
  },
};
