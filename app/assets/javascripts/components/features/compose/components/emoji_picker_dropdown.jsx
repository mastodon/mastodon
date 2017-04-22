import Dropdown, { DropdownTrigger, DropdownContent } from 'react-simple-dropdown';
import EmojiPicker from 'emojione-picker';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  emoji: { id: 'emoji_button.label', defaultMessage: 'Insert emoji' },
  emoji_search: { id: 'emoji_button.search', defaultMessage: 'Search...' }
});

const settings = {
  imageType: 'png',
  sprites: false,
  imagePathPNG: '/emoji/'
};

const style = {
  position: 'absolute',
  right: '5px',
  top: '5px'
};

class EmojiPickerDropdown extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.setRef = this.setRef.bind(this);
    this.handleChange = this.handleChange.bind(this);
  }

  setRef (c) {
    this.dropdown = c;
  }

  handleChange (data) {
    this.dropdown.hide();
    this.props.onPickEmoji(data);
  }

  render () {
    const { intl } = this.props;

    return (
      <Dropdown ref={this.setRef} style={style}>
        <DropdownTrigger className='emoji-button' title={intl.formatMessage(messages.emoji)} style={{ fontSize: `24px`, width: `24px`, lineHeight: `24px`, display: 'block', marginLeft: '2px' }}>
          <img draggable="false" className="emojione" alt="🙂" src="/emoji/1f602.svg" />
        </DropdownTrigger>

        <DropdownContent className='dropdown__left light'>
          <EmojiPicker emojione={settings} onChange={this.handleChange} searchPlaceholder={intl.formatMessage(messages.emoji_search)} search={true} />
        </DropdownContent>
      </Dropdown>
    );
  }

}

EmojiPickerDropdown.propTypes = {
  intl: PropTypes.object.isRequired,
  onPickEmoji: PropTypes.func.isRequired
};

export default injectIntl(EmojiPickerDropdown);
