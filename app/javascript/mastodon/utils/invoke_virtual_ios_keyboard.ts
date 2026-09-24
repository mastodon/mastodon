import classes from './invoke_virtual_ios_keyboard.module.css';

export function invokeVirtualIosKeyboard() {
  // To ensure that a virtual keyboard is shown on iOS when
  // auto-focusing an input, we create a dummy input that
  // we briefly attach to the DOM to capture focus, then let
  // our regular FocusNavigationTarget handling take over.
  const dummyInput = document.createElement('input');
  dummyInput.className = classes.dummyInput ?? '';
  dummyInput.onblur = () => {
    // Cleanup: Remove the dummy input after focus was moved away from it
    dummyInput.remove();
  };
  document.body.appendChild(dummyInput);
  dummyInput.focus();
}
