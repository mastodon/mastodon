import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import IconButton from '../../../components/icon_button';
import { defineMessages, injectIntl } from 'react-intl';
import UploadProgressContainer from '../containers/upload_progress_container';
import { Motion, spring } from 'react-motion';

const messages = defineMessages({
  undo: { id: 'upload_form.undo', defaultMessage: 'Undo' }
});

const UploadForm = React.createClass({

  propTypes: {
    media: ImmutablePropTypes.list.isRequired,
    onRemoveFile: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { intl, media } = this.props;

    const uploads = media.map(attachment =>
      <div key={attachment.get('id')} style={{ marginBottom: '10px' }}>
        <Motion defaultStyle={{ scale: 0.8 }} style={{ scale: spring(1, { stiffness: 180, damping: 12 }) }}>
          {({ scale }) =>
            <div style={{ transform: `translateZ(0) scale(${scale})`, width: '100%', height: '100px', borderRadius: '4px', background: `url(${attachment.get('preview_url')}) no-repeat center`, backgroundSize: 'cover' }}>
              <IconButton icon='times' title={intl.formatMessage(messages.undo)} size={36} onClick={this.props.onRemoveFile.bind(this, attachment.get('id'))} />
            </div>
          }
        </Motion>
      </div>
    );

    return (
      <div style={{ marginBottom: '20px', padding: '10px', overflow: 'hidden', flexShrink: '0' }}>
        <UploadProgressContainer />
        {uploads}
      </div>
    );
  }

});

export default injectIntl(UploadForm);
