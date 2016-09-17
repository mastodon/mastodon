import PureRenderMixin    from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import UploadButton       from './upload_button';
import IconButton         from './icon_button';

const UploadForm = React.createClass({

  propTypes: {
    media: ImmutablePropTypes.list.isRequired,
    is_uploading: React.PropTypes.bool,
    onSelectFile: React.PropTypes.func.isRequired,
    onRemoveFile: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    let uploads = this.props.media.map(function (attachment) {
      return (
        <div key={attachment.get('id')} style={{ borderRadius: '4px', marginBottom: '10px' }} className='transparent-background'>
          <div style={{ width: '100%', height: '100px', borderRadius: '4px', background: `url(${attachment.get('preview_url')}) no-repeat center`, backgroundSize: 'cover' }}>
            <IconButton icon='times' title='Undo' size={36} onClick={() => this.props.onRemoveFile(attachment.get('id'))} />
          </div>
        </div>
      );
    }.bind(this));

    const noMoreAllowed = (this.props.media.some(m => m.get('type') === 'video')) || (this.props.media.size > 3);

    return (
      <div style={{ marginBottom: '20px', padding: '10px', paddingTop: '0' }}>
        <UploadButton onSelectFile={this.props.onSelectFile} disabled={this.props.is_uploading || noMoreAllowed } />

        <div style={{ marginTop: '10px', overflow: 'hidden' }}>
          {uploads}
        </div>
      </div>
    );
  }

});

export default UploadForm;
