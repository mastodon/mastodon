import React, { memo, useEffect, useState } from 'react';

type Props = React.PropsWithChildren<{
  show: boolean;
  transitionDelay?: number;
}>;

const InlineAlert = ({ show, children, transitionDelay = 200 }: Props) => {
  const [mountMessage, setMountMessage] = useState(show);
  // This component uses javascript timers to debounce hiding the content of this element
  // when show changes from true to false. JavaScript timers must be used instead of
  // listening for the transitionEnd event because if a user has elected to reduce motion
  // in Mastodon, no transitionEnd event will be fired.
  //
  // A result, one must ensure that `transitionDelay` is always equal to the transition
  // specified for .inline-alert in components.scss.

  useEffect(() => {
    let handle: NodeJS.Timeout | undefined = undefined;

    if (show) {
      setMountMessage(true);
    } else {
      handle = setTimeout(() => {
        setMountMessage(false);
      }, transitionDelay);
    }

    return () => {
      clearTimeout(handle);
    };
  }, [show, transitionDelay]);

  return (
    <span
      aria-live='polite'
      role='status'
      className='inline-alert'
      style={{ opacity: show ? 1 : 0 }}
    >
      {mountMessage && children}
    </span>
  );
};

const memoized = memo(InlineAlert);
export { memoized as InlineAlert };
