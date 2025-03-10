// This hook allows a component to signal that it's done rendering in a way that
// can be used by e.g. our embed code to determine correct iframe height

let renderSignalReceived = false;

type Callback = () => void;

let onInitialRender: Callback;

export const afterInitialRender = (callback: Callback) => {
  if (renderSignalReceived) {
    callback();
  } else {
    onInitialRender = callback;
  }
};

export const useRenderSignal = () => {
  return () => {
    if (renderSignalReceived) {
      return;
    }

    renderSignalReceived = true;

    if (typeof onInitialRender !== 'undefined') {
      window.requestAnimationFrame(() => {
        onInitialRender();
      });
    }
  };
};
