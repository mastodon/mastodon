import Dropdown, { DropdownTrigger, DropdownContent } from 'react-simple-dropdown';
import EmojiPicker from 'emojione-picker';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  emoji: { id: 'emoji_button.label', defaultMessage: 'Insert emoji' },
  emoji_search: { id: 'emoji_button.search', defaultMessage: 'Search...' },
  people: { id: 'emoji_button.people', defaultMessage: 'People' },
  nature: { id: 'emoji_button.nature', defaultMessage: 'Nature' },
  food: { id: 'emoji_button.food', defaultMessage: 'Food & Drink' },
  activity: { id: 'emoji_button.activity', defaultMessage: 'Activity' },
  travel: { id: 'emoji_button.travel', defaultMessage: 'Travel & Places' },
  objects: { id: 'emoji_button.objects', defaultMessage: 'Objects' },
  symbols: { id: 'emoji_button.symbols', defaultMessage: 'Symbols' },
  flags: { id: 'emoji_button.flags', defaultMessage: 'Flags' }
});

const settings = {
  imageType: 'png',
  sprites: false,
  imagePathPNG: '/emoji/'
};

const dropdownStyle = {
  position: 'absolute',
  right: '5px',
  top: '5px'
};

const dropdownTriggerStyle = {
  display: 'block',
  fontSize: '24px',
  lineHeight: '24px',
  marginLeft: '2px',
  width: '24px'
}

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

    const categories = {
      people: {
        title: intl.formatMessage(messages.people),
        emoji: 'smile',
      },
      nature: {
        title: intl.formatMessage(messages.nature),
        emoji: 'hamster',
      },
      food: {
        title: intl.formatMessage(messages.food),
        emoji: 'pizza',
      },
      activity: {
        title: intl.formatMessage(messages.activity),
        emoji: 'soccer',
      },
      travel: {
        title: intl.formatMessage(messages.travel),
        emoji: 'earth_americas',
      },
      objects: {
        title: intl.formatMessage(messages.objects),
        emoji: 'bulb',
      },
      symbols: {
        title: intl.formatMessage(messages.symbols),
        emoji: 'clock9',
      },
      flags: {
        title: intl.formatMessage(messages.flags),
        emoji: 'flag_gb',
      }
    }

    return (
      <Dropdown ref={this.setRef} style={dropdownStyle}>
        <DropdownTrigger className='emoji-button' title={intl.formatMessage(messages.emoji)} style={dropdownTriggerStyle}>
          <img draggable="false" className="emojione" alt="🙂" src="/emoji/1f602.svg" />
        </DropdownTrigger>

        <DropdownContent className='dropdown__left'>
          <EmojiPicker emojione={settings} onChange={this.handleChange} searchPlaceholder={intl.formatMessage(messages.emoji_search)} categories={categories} search={true} />
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
