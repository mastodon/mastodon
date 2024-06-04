import PropTypes from 'prop-types';
import { useState, useCallback, forwardRef } from 'react';

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

const HotKeys = forwardRef(({ handlers, children }, ref) => {
  const [isFocused, setIsFocused] = useState(false);

  const stopCallback = (event, element) => {
    return ['TEXTAREA', 'SELECT', 'INPUT'].includes(element.tagName);
  };

  const handleFocus = useCallback(() => {
    setIsFocused(true);
  }, []);

  const handleBlur = useCallback(() => {
    setIsFocused(false);
  }, []);

  const useRegisterHotkey = (keys, action) => {
    useHotkeys(
      keys,
      (event) => {
        try {
          const element = event.target;
          if (!stopCallback(event, element)) {
            handlers[action](event);
          }
        } catch (error) {
          console.warn(`"${action}" is not defined here`);
        }
      },
      { enabled: isFocused }
    );
  };
  
  useRegisterHotkey(Array.isArray(keyMap.help) ? keyMap.help : [keyMap.help], 'help');
  useRegisterHotkey(Array.isArray(keyMap.new) ? keyMap.new : [keyMap.new], 'new');
  useRegisterHotkey(Array.isArray(keyMap.search) ? keyMap.search : [keyMap.search], 'search');
  useRegisterHotkey(Array.isArray(keyMap.forceNew) ? keyMap.forceNew : [keyMap.forceNew], 'forceNew');
  useRegisterHotkey(Array.isArray(keyMap.toggleComposeSpoilers) ? keyMap.toggleComposeSpoilers : [keyMap.toggleComposeSpoilers], 'toggleComposeSpoilers');
  useRegisterHotkey(Array.isArray(keyMap.focusColumn) ? keyMap.focusColumn : [keyMap.focusColumn], 'focusColumn');
  useRegisterHotkey(Array.isArray(keyMap.reply) ? keyMap.reply : [keyMap.reply], 'reply');
  useRegisterHotkey(Array.isArray(keyMap.favourite) ? keyMap.favourite : [keyMap.favourite], 'favourite');
  useRegisterHotkey(Array.isArray(keyMap.boost) ? keyMap.boost : [keyMap.boost], 'boost');
  useRegisterHotkey(Array.isArray(keyMap.mention) ? keyMap.mention : [keyMap.mention], 'mention');
  useRegisterHotkey(Array.isArray(keyMap.open) ? keyMap.open : [keyMap.open], 'open');
  useRegisterHotkey(Array.isArray(keyMap.openProfile) ? keyMap.openProfile : [keyMap.openProfile], 'openProfile');
  useRegisterHotkey(Array.isArray(keyMap.moveDown) ? keyMap.moveDown : [keyMap.moveDown], 'moveDown');
  useRegisterHotkey(Array.isArray(keyMap.moveUp) ? keyMap.moveUp : [keyMap.moveUp], 'moveUp');
  useRegisterHotkey(Array.isArray(keyMap.back) ? keyMap.back : [keyMap.back], 'back');
  useRegisterHotkey(Array.isArray(keyMap.goToHome) ? keyMap.goToHome : [keyMap.goToHome], 'goToHome');
  useRegisterHotkey(Array.isArray(keyMap.goToNotifications) ? keyMap.goToNotifications : [keyMap.goToNotifications], 'goToNotifications');
  useRegisterHotkey(Array.isArray(keyMap.goToLocal) ? keyMap.goToLocal : [keyMap.goToLocal], 'goToLocal');
  useRegisterHotkey(Array.isArray(keyMap.goToFederated) ? keyMap.goToFederated : [keyMap.goToFederated], 'goToFederated');
  useRegisterHotkey(Array.isArray(keyMap.goToDirect) ? keyMap.goToDirect : [keyMap.goToDirect], 'goToDirect');
  useRegisterHotkey(Array.isArray(keyMap.goToStart) ? keyMap.goToStart : [keyMap.goToStart], 'goToStart');
  useRegisterHotkey(Array.isArray(keyMap.goToFavourites) ? keyMap.goToFavourites : [keyMap.goToFavourites], 'goToFavourites');
  useRegisterHotkey(Array.isArray(keyMap.goToPinned) ? keyMap.goToPinned : [keyMap.goToPinned], 'goToPinned');
  useRegisterHotkey(Array.isArray(keyMap.goToProfile) ? keyMap.goToProfile : [keyMap.goToProfile], 'goToProfile');
  useRegisterHotkey(Array.isArray(keyMap.goToBlocked) ? keyMap.goToBlocked : [keyMap.goToBlocked], 'goToBlocked');
  useRegisterHotkey(Array.isArray(keyMap.goToMuted) ? keyMap.goToMuted : [keyMap.goToMuted], 'goToMuted');
  useRegisterHotkey(Array.isArray(keyMap.goToRequests) ? keyMap.goToRequests : [keyMap.goToRequests], 'goToRequests');
  useRegisterHotkey(Array.isArray(keyMap.toggleHidden) ? keyMap.toggleHidden : [keyMap.toggleHidden], 'toggleHidden');
  useRegisterHotkey(Array.isArray(keyMap.toggleSensitive) ? keyMap.toggleSensitive : [keyMap.toggleSensitive], 'toggleSensitive');
  useRegisterHotkey(Array.isArray(keyMap.openMedia) ? keyMap.openMedia : [keyMap.openMedia], 'openMedia');

  return (
    <div
      ref={ref}
      tabIndex={-1}
      onFocus={handleFocus}
      onBlur={handleBlur}
    >
      {children}
    </div>
  );
});

HotKeys.propTypes = {
  handlers: PropTypes.object.isRequired,
  children: PropTypes.node,
};

export default HotKeys;
