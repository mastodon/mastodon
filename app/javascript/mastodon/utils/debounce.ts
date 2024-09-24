import { debounce } from 'lodash';

import type { AppDispatch } from 'mastodon/store';

export const debounceWithDispatchAndArguments = <T>(
  fn: (dispatch: AppDispatch, ...args: T[]) => void,
  { delay = 100 },
) => {
  let argumentBuffer: T[] = [];
  let dispatchBuffer: AppDispatch;

  const wrapped = debounce(() => {
    const tmpBuffer = argumentBuffer;
    argumentBuffer = [];
    fn(dispatchBuffer, ...tmpBuffer);
  }, delay);

  return (dispatch: AppDispatch, ...args: T[]) => {
    dispatchBuffer = dispatch;
    argumentBuffer.push(...args);
    wrapped();
  };
};
