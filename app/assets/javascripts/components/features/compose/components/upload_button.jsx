import PureRenderMixin from 'react-addons-pure-render-mixin';
import IconButton from '../../../components/icon_button';

const UploadButton = React.createClass({

  propTypes: {
    disabled: React.PropTypes.bool,
    onSelectFile: React.PropTypes.func.isRequired,
    style: React.PropTypes.object
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
    return (
      <div style={this.props.style}>
        <IconButton icon='photo' title='Add media' disabled={this.props.disabled} onClick={this.handleClick} size={24} />
        <input ref={this.setRef} type='file' multiple={false} onChange={this.handleChange} disabled={this.props.disabled} style={{ display: 'none' }} />
      </div>
    );
  }

});

export default UploadButton;
