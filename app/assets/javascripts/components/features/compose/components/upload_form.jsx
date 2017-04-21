import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import IconButton from '../../../components/icon_button';
import { defineMessages, injectIntl } from 'react-intl';
import UploadProgressContainer from '../containers/upload_progress_container';
import { Motion, spring } from 'react-motion';

const messages = defineMessages({
  undo: { id: 'upload_form.undo', defaultMessage: 'Undo' }
});

class UploadForm extends React.PureComponent {

  render () {
    const { intl, media } = this.props;

    const uploads = media.map(attachment =>
      <div key={attachment.get('id')} style={{ margin: '5px', flex: '1 1 0' }}>
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
      <div style={{ overflow: 'hidden' }}>
        <UploadProgressContainer />
        <div style={{ display: 'flex', padding: '5px' }}>{uploads}</div>
      </div>
    );
  }

}

UploadForm.propTypes = {
  media: ImmutablePropTypes.list.isRequired,
  onRemoveFile: PropTypes.func.isRequired,
  intl: PropTypes.object.isRequired
};

export default injectIntl(UploadForm);
