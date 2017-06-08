import { MODAL_OPEN, MODAL_CLOSE } from '../actions/modal';

export default function loadingBarMiddleware(history) {
  return ({ dispatch }) => next => (action) => {
    switch (action.type) {
    case MODAL_OPEN:
      // Push a fake history entry, so that when the user
      // navigates back we can detect it and close the modal
      // The state is just to make this entry different
      // from the current one (otherwise push is a noop)
      history.push({
        pathname: history.getCurrentLocation().pathname,
        state: { modal: true },
      });
      break;
    case MODAL_CLOSE:
      if (!action.skipGoingBack) {
        // Remove the fake history entry
        history.goBack();
      }
      break;
    }

    return next(action);
  };
}
