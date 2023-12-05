import { Map as ImmutableMap } from 'immutable';
import { connect } from 'react-redux';
import { createSelector } from 'reselect';

import { useEmoji } from '../../../actions/emojis';
import { changeSetting } from '../../../actions/settings';
import EmojiPickerDropdown from '../components/emoji_picker_dropdown';

const perLine = 8;
const lines   = 2;

const DEFAULTS = [
  '+1',
  'grinning',
  'kissing_heart',
  'heart_eyes',
  'laughing',
  'stuck_out_tongue_winking_eye',
  'sweat_smile',
  'joy',
  'yum',
  'disappointed',
  'thinking_face',
  'weary',
  'sob',
  'sunglasses',
  'heart',
  'ok_hand',
];

const getFrequentlyUsedEmojis = createSelector([
  state => state.getIn(['settings', 'frequentlyUsedEmojis'], ImmutableMap()),
], emojiCounters => {
  let emojis = emojiCounters
    .keySeq()
    .sort((a, b) => emojiCounters.get(a) - emojiCounters.get(b))
    .reverse()
    .slice(0, perLine * lines)
    .toArray();

  if (emojis.length < DEFAULTS.length) {
    let uniqueDefaults = DEFAULTS.filter(emoji => !emojis.includes(emoji));
    emojis = emojis.concat(uniqueDefaults.slice(0, DEFAULTS.length - emojis.length));
  }

  return emojis;
});

const getCustomEmojis = createSelector([
  state => state.get('custom_emojis'),
], emojis => emojis.filter(e => e.get('visible_in_picker')).sort((a, b) => {
  const aShort = a.get('shortcode').toLowerCase();
  const bShort = b.get('shortcode').toLowerCase();

  if (aShort < bShort) {
    return -1;
  } else if (aShort > bShort ) {
    return 1;
  } else {
    return 0;
  }
}));

const mapStateToProps = state => ({
  custom_emojis: getCustomEmojis(state),
  skinTone: state.getIn(['settings', 'skinTone']),
  frequentlyUsedEmojis: getFrequentlyUsedEmojis(state),
});

const mapDispatchToProps = (dispatch, { onPickEmoji }) => ({
  onSkinTone: skinTone => {
    dispatch(changeSetting(['skinTone'], skinTone));
  },

  onPickEmoji: emoji => {
    // eslint-disable-next-line react-hooks/rules-of-hooks -- this is not a react hook
    dispatch(useEmoji(emoji));

    if (onPickEmoji) {
      onPickEmoji(emoji);
    }
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(EmojiPickerDropdown);
