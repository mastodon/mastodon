import { connect } from 'react-redux';
import EmojiPickerDropdown from '../components/emoji_picker_dropdown';

const mapStateToProps = state => ({
  custom_emojis: state.get('custom_emojis'),
});

export default connect(mapStateToProps)(EmojiPickerDropdown);
