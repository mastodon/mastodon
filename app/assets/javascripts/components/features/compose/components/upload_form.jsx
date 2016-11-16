import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import IconButton from '../../../components/icon_button';
import { injectIntl } from 'react-intl';

const UploadForm = React.createClass({

  propTypes: {
    media: ImmutablePropTypes.list.isRequired,
    is_uploading: React.PropTypes.bool,
    onRemoveFile: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { intl } = this.props;

    const uploads = this.props.media.map(attachment => (
      <div key={attachment.get('id')} style={{ borderRadius: '4px', marginBottom: '10px' }} className='transparent-background'>
        <div style={{ width: '100%', height: '100px', borderRadius: '4px', background: `url(${attachment.get('preview_url')}) no-repeat center`, backgroundSize: 'cover' }}>
          <IconButton icon='times' title={intl.formatMessage({ id: 'upload_form.undo', defaultMessage: 'Undo' })} size={36} onClick={this.props.onRemoveFile.bind(this, attachment.get('id'))} />
        </div>
      </div>
    ));

    return (
      <div style={{ marginBottom: '20px', padding: '10px', overflow: 'hidden' }}>
        {uploads}
      </div>
    );
  }

});

export default injectIntl(UploadForm);
