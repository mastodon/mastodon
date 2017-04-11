import Dropdown, { DropdownTrigger, DropdownContent } from 'react-simple-dropdown';
import EmojiPicker from 'emojione-picker';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  emoji: { id: 'emoji_button.label', defaultMessage: 'Insert emoji' }
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

const EmojiPickerDropdown = React.createClass({

  propTypes: {
    intl: React.PropTypes.object.isRequired,
    onPickEmoji: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  setRef (c) {
    this.dropdown = c;
  },

  handleChange (data) {
    this.dropdown.hide();
    this.props.onPickEmoji(data);
  },

  render () {
    const { intl } = this.props;

    return (
      <Dropdown ref={this.setRef} style={style}>
        <DropdownTrigger className='emoji-button' title={intl.formatMessage(messages.emoji)} style={{ fontSize: `24px`, width: `24px`, lineHeight: `24px`, display: 'block', marginLeft: '2px' }}>
          <img draggable="false" className="emojione" alt="🙂" src="/emoji/1f602.svg" />
        </DropdownTrigger>

        <DropdownContent className='dropdown__left'>
          <EmojiPicker emojione={settings} onChange={this.handleChange} search={true} />
        </DropdownContent>
      </Dropdown>
    );
  }

});

export default injectIntl(EmojiPickerDropdown);
