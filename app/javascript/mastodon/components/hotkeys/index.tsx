import { useEffect, useRef } from 'react';

import { normalizeKey, isKeyboardEvent } from './utils';

/**
 * In case of multiple hotkeys matching the pressed key(s),
 * the hotkey with a higher priority is selected. All others
 * are ignored.
 */
const hotkeyPriority = { singleKey: 0, combo: 1, sequence: 2 } as const;

/**
 * This type of function receives a keyboard event and an array of
 * previously pressed keys (within the last second), and returns
 * `isMatch` (whether the pressed keys match a hotkey) and `priority`
 * (a weighting used to resolve conflicts when two hotkeys match the
 * pressed keys)
 */
type KeyMatcher = (
  event: KeyboardEvent,
  bufferedKeys?: string[],
) => {
  /**
   * Whether the event.key matches the hotkey
   */
  isMatch: boolean;
  /**
   * If there are multiple matching hotkeys, the
   * first one with the highest priority will be handled
   */
  priority: (typeof hotkeyPriority)[keyof typeof hotkeyPriority];
};

/**
 * Matches a single key
 */
function just(keyName: string): KeyMatcher {
  return (event) => ({
    isMatch:
      normalizeKey(event.key) === keyName &&
      !event.altKey &&
      !event.ctrlKey &&
      !event.metaKey,
    priority: hotkeyPriority.singleKey,
  });
}

/**
 * Matches any single key out of those provided
 */
function any(...keys: string[]): KeyMatcher {
  return (event) => ({
    isMatch: keys.some((keyName) => just(keyName)(event).isMatch),
    priority: hotkeyPriority.singleKey,
  });
}

/**
 * Matches a single key combined with the option/alt modifier
 */
function optionPlus(key: string): KeyMatcher {
  return (event) => ({
    // Matching against event.code here as alt combos are often
    // mapped to other characters
    isMatch: event.altKey && event.code === `Key${key.toUpperCase()}`,
    priority: hotkeyPriority.combo,
  });
}

/**
 * Matches when all provided keys are pressed in sequence.
 */
function sequence(...sequence: string[]): KeyMatcher {
  return (event, bufferedKeys) => {
    const lastKeyInSequence = sequence.at(-1);
    const startOfSequence = sequence.slice(0, -1);
    const relevantBufferedKeys = bufferedKeys?.slice(-startOfSequence.length);

    const bufferMatchesStartOfSequence =
      !!relevantBufferedKeys &&
      startOfSequence.join('') === relevantBufferedKeys.join('');

    return {
      isMatch:
        bufferMatchesStartOfSequence &&
        normalizeKey(event.key) === lastKeyInSequence,
      priority: hotkeyPriority.sequence,
    };
  };
}

/**
 * This is a map of all global hotkeys we support.
 * To trigger a hotkey, a handler with a matching name must be
 * provided to the `useHotkeys` hook or `Hotkeys` component.
 */
const hotkeyMatcherMap = {
  help: just('?'),
  search: any('s', '/'),
  back: just('backspace'),
  new: just('n'),
  forceNew: optionPlus('n'),
  focusColumn: any('1', '2', '3', '4', '5', '6', '7', '8', '9'),
  focusLoadMore: just('l'),
  reply: just('r'),
  favourite: just('f'),
  boost: just('b'),
  quote: just('q'),
  mention: just('m'),
  open: any('enter', 'o'),
  openProfile: just('p'),
  moveDown: just('j'),
  moveUp: just('k'),
  moveToTop: just('0'),
  toggleHidden: just('x'),
  toggleSensitive: just('h'),
  toggleComposeSpoilers: optionPlus('x'),
  openMedia: just('e'),
  onTranslate: just('t'),
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
  cheat: sequence(
    'up',
    'up',
    'down',
    'down',
    'left',
    'right',
    'left',
    'right',
    'b',
    'a',
    'enter',
  ),
} as const;

type HotkeyName = keyof typeof hotkeyMatcherMap;

export type HandlerMap = Partial<
  Record<HotkeyName, (event: KeyboardEvent) => void>
>;

export function useHotkeys<T extends HTMLElement>(handlers: HandlerMap) {
  const ref = useRef<T>(null);
  const bufferedKeys = useRef<string[]>([]);
  const sequenceTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

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
        isKeyboardEvent(event) &&
        !event.defaultPrevented &&
        !['input', 'textarea', 'select'].includes(tagName) &&
        !(
          ['a', 'button'].includes(tagName) &&
          normalizeKey(event.key) === 'enter'
        );

      if (shouldHandleEvent) {
        const matchCandidates: {
          // A candidate will be have an undefined handler if it's matched,
          // but handled in a parent component rather than this one.
          handler: ((event: KeyboardEvent) => void) | undefined;
          priority: number;
        }[] = [];

        (Object.keys(hotkeyMatcherMap) as HotkeyName[]).forEach(
          (handlerName) => {
            const handler = handlersRef.current[handlerName];
            const hotkeyMatcher = hotkeyMatcherMap[handlerName];

            const { isMatch, priority } = hotkeyMatcher(
              event,
              bufferedKeys.current,
            );

            if (isMatch) {
              matchCandidates.push({ handler, priority });
            }
          },
        );

        // Sort all matches by priority
        matchCandidates.sort((a, b) => b.priority - a.priority);

        const bestMatchingHandler = matchCandidates.at(0)?.handler;
        if (bestMatchingHandler) {
          bestMatchingHandler(event);
          event.stopPropagation();
          event.preventDefault();
        }

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

/**
 * The Hotkeys component allows us to globally register keyboard combinations
 * under a name and assign actions to them, either globally or scoped to a portion
 * of the app.
 *
 * ### How to use
 *
 * To add a new hotkey, add its key combination to the `hotkeyMatcherMap` object
 * and give it a name.
 *
 * Use the `<Hotkeys>` component or the `useHotkeys` hook in the part of of the app
 * where you want to handle the action, and pass in a handlers object.
 *
 * ```tsx
 * <Hotkeys handlers={{open: openStatus}} />
 * ```
 *
 * Now this function will be called when the 'open' hotkey is pressed by the user.
 */
export const Hotkeys: React.FC<{
  /**
   * An object containing functions to be run when a hotkey is pressed.
   * The key must be the name of a registered hotkey, e.g. "help" or "search"
   */
  handlers: HandlerMap;
  /**
   * When enabled, hotkeys will be matched against the document root
   * rather than only inside of this component's DOM node.
   */
  global?: boolean;
  /**
   * Allow the rendered `div` to be focused
   */
  focusable?: boolean;
  children: React.ReactNode;
}> = ({ handlers, global, focusable = true, children }) => {
  const ref = useHotkeys<HTMLDivElement>(handlers);

  return (
    <div ref={global ? undefined : ref} tabIndex={focusable ? -1 : undefined}>
      {children}
    </div>
  );
};
