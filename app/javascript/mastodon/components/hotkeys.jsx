import React, { forwardRef, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useHotkeys } from 'react-hotkeys-hook';

const HotKeys = forwardRef(({ handlers, options, children }, ref) => {
  // Custom hook to register multiple hotkeys
  const useMultipleHotkeys = (handlers, options) => {
    Object.entries(handlers).forEach(([key, handler]) => {
      useHotkeys(key, handler, options);
    });
  };

  useMultipleHotkeys(handlers, options);

  return <div ref={ref}>{children}</div>;
});

HotKeys.propTypes = {
  handlers: PropTypes.object.isRequired,
  options: PropTypes.object,
  children: PropTypes.node,
};

export default HotKeys;
