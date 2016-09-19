import PureRenderMixin from 'react-addons-pure-render-mixin';
import Button          from '../../../components/button';

const UploadButton = React.createClass({

  propTypes: {
    disabled: React.PropTypes.bool,
    onSelectFile: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  handleChange (e) {
    if (e.target.files.length > 0) {
      this.props.onSelectFile(e.target.files);
    }
  },

  handleClick () {
    this.refs.fileElement.click();
  },

  render () {
    return (
      <div>
        <Button disabled={this.props.disabled} onClick={this.handleClick} block={true}>
          <i className='fa fa-fw fa-photo' /> Add images
        </Button>

        <input ref='fileElement' type='file' multiple={false} onChange={this.handleChange} disabled={this.props.disabled} style={{ display: 'none' }} />
      </div>
    );
  }

});

export default UploadButton;
