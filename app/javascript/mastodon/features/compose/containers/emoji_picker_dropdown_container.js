import { connect } from 'react-redux';
import EmojiPickerDropdown from '../components/emoji_picker_dropdown';

const mapStateToProps = state => ({
  custom_emojis: state.get('custom_emojis'),
  autoPlay: state.getIn(['meta', 'auto_play_gif']),
});

export default connect(mapStateToProps)(EmojiPickerDropdown);
