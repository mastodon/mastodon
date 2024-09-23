import type { AppDispatch } from 'mastodon/store';

export const debounceWithDispatchAndArguments = <T>(
  fn: (dispatch: AppDispatch, ...args: T[]) => void,
  { delay = 100 },
) => {
  let argumentBuffer: T[] = [];
  let timeout: ReturnType<typeof setTimeout>;
  let dispatchBuffer: AppDispatch;

  const flush = () => {
    const tmpBuffer = argumentBuffer;
    argumentBuffer = [];
    fn(dispatchBuffer, ...tmpBuffer);
  };

  return (dispatch: AppDispatch, ...args: T[]) => {
    dispatchBuffer = dispatch;
    argumentBuffer.push(...args);
    clearTimeout(timeout);
    timeout = setTimeout(flush, delay);
  };
};
