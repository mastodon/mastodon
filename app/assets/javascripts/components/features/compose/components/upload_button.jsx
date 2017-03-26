import PureRenderMixin from 'react-addons-pure-render-mixin';
import IconButton from '../../../components/icon_button';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  upload: { id: 'upload_button.label', defaultMessage: 'Add media' }
});

const iconStyle = {
  lineHeight: '27px',
  height: null
};

const UploadButton = React.createClass({

  propTypes: {
    disabled: React.PropTypes.bool,
    onSelectFile: React.PropTypes.func.isRequired,
    style: React.PropTypes.object,
    resetFileKey: React.PropTypes.number,
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  handleChange (e) {
    if (e.target.files.length > 0) {
      this.props.onSelectFile(e.target.files);
    }
  },

  handleClick () {
    this.fileElement.click();
  },

  setRef (c) {
    this.fileElement = c;
  },

  render () {
    const { intl, resetFileKey, disabled } = this.props;

    return (
      <div style={this.props.style}>
        <IconButton icon='camera' title={intl.formatMessage(messages.upload)} disabled={disabled} onClick={this.handleClick} style={iconStyle} size={18} inverted />
        <input key={resetFileKey} ref={this.setRef} type='file' multiple={false} onChange={this.handleChange} disabled={disabled} style={{ display: 'none' }} />
      </div>
    );
  }

});

export default injectIntl(UploadButton);
