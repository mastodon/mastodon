import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import IconButton from '../../../components/icon_button';
import { defineMessages, injectIntl } from 'react-intl';
import UploadProgressContainer from '../containers/upload_progress_container';
import Motion from 'react-motion/lib/Motion';
import spring from 'react-motion/lib/spring';

const messages = defineMessages({
  undo: { id: 'upload_form.undo', defaultMessage: 'Undo' },
});

@injectIntl
export default class UploadForm extends React.PureComponent {

  static propTypes = {
    media: ImmutablePropTypes.list.isRequired,
    onRemoveFile: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  onRemoveFile = (e) => {
    const id = Number(e.currentTarget.parentElement.getAttribute('data-id'));
    this.props.onRemoveFile(id);
  }

  render () {
    const { intl, media } = this.props;

    const uploads = media.map(attachment =>
      <div className='compose-form__upload' key={attachment.get('id')}>
        <Motion defaultStyle={{ scale: 0.8 }} style={{ scale: spring(1, { stiffness: 180, damping: 12 }) }}>
          {({ scale }) =>
            <div className='compose-form__upload-thumbnail' data-id={attachment.get('id')} style={{ transform: `translateZ(0) scale(${scale})`, backgroundImage: `url(${attachment.get('preview_url')})` }}>
              <IconButton icon='times' title={intl.formatMessage(messages.undo)} size={36} onClick={this.onRemoveFile} />
            </div>
          }
        </Motion>
      </div>
    );

    return (
      <div className='compose-form__upload-wrapper'>
        <UploadProgressContainer />
        <div className='compose-form__uploads-wrapper'>{uploads}</div>
      </div>
    );
  }

}
