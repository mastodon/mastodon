import classes from './invoke_virtual_ios_keyboard.module.css';

/**
 * To ensure that a virtual keyboard is shown on iOS when
 * auto-focusing an input that isn't available synchronously,
 * we create a dummy input that we briefly attach to the DOM
 * to capture focus, then let our regular FocusNavigationTarget
 * handling take over.
 * Ensure that this is only used when you're
 */
export function invokeVirtualIosKeyboard() {
  const prevFocusedElement = document.activeElement as HTMLElement | null;
  let timeout: ReturnType<typeof setTimeout> | null = null;

  const dummyInput = document.createElement('input');
  dummyInput.className = classes.dummyInput ?? '';

  dummyInput.onfocus = () => {
    // If no navigation has occurred after 2 seconds,
    // return focus to the previously focused element
    timeout = setTimeout(() => {
      prevFocusedElement?.focus();
    }, 2000);
  };

  dummyInput.onblur = () => {
    if (timeout) {
      clearTimeout(timeout);
    }
    // Cleanup: Remove the dummy input after focus was moved away from it
    dummyInput.remove();
  };

  document.body.appendChild(dummyInput);
  dummyInput.focus();
}
