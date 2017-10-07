import { connect } from 'react-redux';
import EmojiPickerDropdown from '../components/emoji_picker_dropdown';
import { changeSetting } from '../../../actions/settings';

const mapStateToProps = state => ({
  custom_emojis: state.get('custom_emojis'),
  autoPlay: state.getIn(['meta', 'auto_play_gif']),
  skinTone: state.getIn(['settings', 'skinTone']),
});

const mapDispatchToProps = dispatch => ({
  onSkinTone: skinTone => {
    dispatch(changeSetting(['skinTone'], skinTone));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(EmojiPickerDropdown);
