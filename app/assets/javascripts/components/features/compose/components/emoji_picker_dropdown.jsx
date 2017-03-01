import Dropdown, { DropdownTrigger, DropdownContent } from 'react-simple-dropdown';
import EmojiPicker from 'emojione-picker';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  emoji: { id: 'emoji_button.label', defaultMessage: 'Emoji' }
});

const settings = {
  imageType: 'png',
  sprites: false,
  imagePathPNG: '/emoji/'
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
      <Dropdown ref={this.setRef} style={{ marginLeft: '5px' }}>
        <DropdownTrigger className='icon-button' title={intl.formatMessage(messages.emoji)} style={{ fontSize: `24px`, width: `24px`, lineHeight: `24px`, marginTop: '-1px', display: 'block', marginLeft: '2px' }}>
          <i className={`fa fa-smile-o`} style={{ verticalAlign: 'middle' }} />
        </DropdownTrigger>

        <DropdownContent>
          <EmojiPicker emojione={settings} onChange={this.handleChange} />
        </DropdownContent>
      </Dropdown>
    );
  }

});

export default injectIntl(EmojiPickerDropdown);
