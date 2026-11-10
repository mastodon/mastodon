/**
 * Check if this composing: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/isComposing
 * and https://developer.mozilla.org/en-US/docs/Web/API/Element/keydown_event#keydown_events_with_ime
 */
export function isKeyComposing(event: React.KeyboardEvent) {
  return (
    event.nativeEvent.isComposing ||
    // eslint-disable-next-line @typescript-eslint/no-deprecated
    event.nativeEvent.keyCode === 229
  );
}
