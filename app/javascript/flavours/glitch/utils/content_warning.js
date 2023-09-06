import { expandSpoilers } from 'flavours/glitch/initial_state';

function _autoUnfoldCW(spoiler_text, skip_unfold_regex) {
  if (!expandSpoilers)
    return false;

  if (!skip_unfold_regex)
    return true;

  let regex = null;

  try {
    regex = new RegExp(skip_unfold_regex.trim(), 'i');
  } catch (e) {
    // Bad regex, skip filters
    return true;
  }

  return !regex.test(spoiler_text);
}

export function autoHideCW(settings, spoiler_text) {
  return !_autoUnfoldCW(spoiler_text, settings.getIn(['content_warnings', 'filter']));
}

export function autoUnfoldCW(settings, status) {
  if (!status)
    return false;

  return _autoUnfoldCW(status.get('spoiler_text'), settings.getIn(['content_warnings', 'filter']));
}
