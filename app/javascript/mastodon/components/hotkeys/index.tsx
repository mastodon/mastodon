import { useEffect, useRef } from 'react';

import { normalizeKey, isKeyboardEvent } from './utils';

type KeyMatcher = (event: KeyboardEvent, bufferedKey?: string) => boolean;

function just(key: string): KeyMatcher {
  return (event: KeyboardEvent) => normalizeKey(event.key) === key;
}

function any(...keys: string[]): KeyMatcher {
  return (event: KeyboardEvent) => keys.some((key) => just(key)(event));
}

function optionPlus(key: string): KeyMatcher {
  return (event: KeyboardEvent) =>
    event.altKey && normalizeKey(event.key) === key;
}

function sequence(firstKey: string, secondKey: string): KeyMatcher {
  return (event: KeyboardEvent, bufferedKey?: string) =>
    !!bufferedKey &&
    bufferedKey === firstKey &&
    normalizeKey(event.key) === secondKey;
}

const hotkeyMatcherMap = {
  help: just('?'),
  new: just('n'),
  search: any('s', '/'),
  forceNew: optionPlus('n'),
  toggleComposeSpoilers: optionPlus('x'),
  focusColumn: any('1', '2', '3', '4', '5', '6', '7', '8', '9'),
  reply: just('r'),
  favourite: just('f'),
  boost: just('b'),
  mention: just('m'),
  open: any('enter', 'o'),
  openProfile: just('p'),
  moveDown: any('down', 'j'),
  moveUp: any('up', 'k'),
  back: just('backspace'),
  goToHome: sequence('g', 'h'),
  goToNotifications: sequence('g', 'n'),
  goToLocal: sequence('g', 'l'),
  goToFederated: sequence('g', 't'),
  goToDirect: sequence('g', 'd'),
  goToStart: sequence('g', 's'),
  goToFavourites: sequence('g', 'f'),
  goToPinned: sequence('g', 'p'),
  goToProfile: sequence('g', 'u'),
  goToBlocked: sequence('g', 'b'),
  goToMuted: sequence('g', 'm'),
  goToRequests: sequence('g', 'r'),
  toggleHidden: just('x'),
  toggleSensitive: just('h'),
  openMedia: just('e'),
  onTranslate: just('t'),
} as const;

type HotkeyName = keyof typeof hotkeyMatcherMap;

type HandlerMap = Partial<Record<HotkeyName, (event: KeyboardEvent) => void>>;

export function useAppHotkeys<T extends HTMLElement>(handlers: HandlerMap) {
  const ref = useRef<T>(null);
  const bufferedKeys = useRef<string[]>([]);
  const sequenceTimer = useRef<NodeJS.Timeout | null>(null);

  /**
   * Store the latest handlers object in a ref so we don't need to
   * add it as a dependency to the main event listener effect
   */
  const handlersRef = useRef(handlers);
  useEffect(() => {
    handlersRef.current = handlers;
  }, [handlers]);

  useEffect(() => {
    const element = ref.current ?? document;

    function listener(event: Event) {
      // Ignore key presses from input, textarea, or select elements
      const tagName = (event.target as HTMLElement).tagName.toLowerCase();
      const shouldHandleEvent =
        !event.defaultPrevented &&
        !['input', 'textarea', 'select'].includes(tagName);

      if (shouldHandleEvent && isKeyboardEvent(event)) {
        // Handle hotkey if its matcher matches
        (Object.keys(hotkeyMatcherMap) as HotkeyName[]).forEach(
          (handlerName) => {
            const handler = handlersRef.current[handlerName];

            if (handler) {
              const lastBufferedKey = bufferedKeys.current.at(-1);
              const hotkeyMatcher = hotkeyMatcherMap[handlerName];

              const isMatch = hotkeyMatcher(event, lastBufferedKey);

              if (isMatch) {
                handler(event);
                event.stopPropagation();
                event.preventDefault();
              }
            }
          },
        );

        // Add last keypress to buffer
        bufferedKeys.current.push(normalizeKey(event.key));

        // Reset the timeout
        if (sequenceTimer.current) {
          clearTimeout(sequenceTimer.current);
        }
        sequenceTimer.current = setTimeout(() => {
          bufferedKeys.current = [];
        }, 1000);
      }
    }
    element.addEventListener('keydown', listener);

    return () => {
      element.removeEventListener('keydown', listener);
      if (sequenceTimer.current) {
        clearTimeout(sequenceTimer.current);
      }
    };
  }, []);

  return ref;
}

export const Hotkeys: React.FC<{
  handlers: HandlerMap;
  global?: boolean;
  focusable?: boolean;
  children: React.ReactNode;
}> = ({ handlers, global, focusable = true, children }) => {
  const ref = useAppHotkeys<HTMLDivElement>(handlers);

  return (
    <div ref={global ? undefined : ref} tabIndex={focusable ? -1 : undefined}>
      {children}
    </div>
  );
};
