<<<<<<< HEAD
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
=======
import React, { useRef, forwardRef } from 'react';
import PropTypes from 'prop-types';
import { useHotkeys } from 'react-hotkeys-hook';

const keyMap = {
  help: '?',
  new: 'n',
  search: 's',
  forceNew: 'option+n',
  toggleComposeSpoilers: 'option+x',
  focusColumn: ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
  reply: 'r',
  favourite: 'f',
  boost: 'b',
  mention: 'm',
  open: ['enter', 'o'],
  openProfile: 'p',
  moveDown: ['down', 'j'],
  moveUp: ['up', 'k'],
  back: 'backspace',
  goToHome: 'g h',
  goToNotifications: 'g n',
  goToLocal: 'g l',
  goToFederated: 'g t',
  goToDirect: 'g d',
  goToStart: 'g s',
  goToFavourites: 'g f',
  goToPinned: 'g p',
  goToProfile: 'g u',
  goToBlocked: 'g b',
  goToMuted: 'g m',
  goToRequests: 'g r',
  toggleHidden: 'x',
  toggleSensitive: 'h',
  openMedia: 'e',
};

const HotKeys = forwardRef(({ handlers, attach, children }, ref) => {
  const internalRef = useRef(null);
  const stopCallback = (event, element) => {
    return ['TEXTAREA', 'SELECT', 'INPUT'].includes(element.tagName);
  }

  // TODO: Review attach and refs
  const attachRef = ref || internalRef;
  const target = attachRef.current || attachRef;

  Object.keys(handlers).forEach((action) => {
    const keys = Array.isArray(keyMap[action]) ? keyMap[action] : [keyMap[action]];
    if (!keys) {
      console.warn(`No keys defined for action "${action}"`);
      return;
    }

    keys.forEach((key) => {
      if (typeof key !== 'string' || key.trim() === '') {
        console.warn(`Invalid key binding: "${key}" for action "${action}"`);
        return;
      }

      useHotkeys(key, (event) => {
        const element = event.target;
        if (!stopCallback(event, element)) {
          handlers[action](event);
        }
      }, { enableOnTags: ['INPUT', 'SELECT', 'TEXTAREA'], element: target });
    });
  });

  return <div ref={attachRef}>{children}</div>;
>>>>>>> a2bfd6e9c (Create HotKeys component)
});

HotKeys.propTypes = {
  handlers: PropTypes.object.isRequired,
<<<<<<< HEAD
  options: PropTypes.object,
=======
  attach: PropTypes.object,
>>>>>>> a2bfd6e9c (Create HotKeys component)
  children: PropTypes.node,
};

export default HotKeys;
