import React from 'react';
import IconButton from '../../../components/icon_button';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';

const messages = defineMessages({
  upload: { id: 'upload_button.label', defaultMessage: 'Add media ({formats})' },
});

const SUPPORTED_FORMATS = 'JPEG, PNG, GIF, WebM, MP4, MOV, OGG, WAV, MP3, FLAC';

const makeMapStateToProps = () => {
  const mapStateToProps = state => ({
    acceptContentTypes: state.getIn(['media_attachments', 'accept_content_types']),
  });

  return mapStateToProps;
};

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

export default @connect(makeMapStateToProps)
@injectIntl
class UploadButton extends ImmutablePureComponent {

  static propTypes = {
    disabled: PropTypes.bool,
    unavailable: PropTypes.bool,
    onSelectFile: PropTypes.func.isRequired,
    style: PropTypes.object,
    resetFileKey: PropTypes.number,
    acceptContentTypes: ImmutablePropTypes.listOf(PropTypes.string).isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleChange = (e) => {
    if (e.target.files.length > 0) {
      this.props.onSelectFile(e.target.files);
    }
  }

  handleClick = () => {
    this.fileElement.click();
  }

  setRef = (c) => {
    this.fileElement = c;
  }

  render () {
    const { intl, resetFileKey, unavailable, disabled, acceptContentTypes } = this.props;

    if (unavailable) {
      return null;
    }

    return (
      <div className='compose-form__upload-button'>
        <IconButton icon='paperclip' title={intl.formatMessage(messages.upload, { formats: SUPPORTED_FORMATS })} disabled={disabled} onClick={this.handleClick} className='compose-form__upload-button-icon' size={18} inverted style={iconStyle} />
        <label>
          <span style={{ display: 'none' }}>{intl.formatMessage(messages.upload, { formats: SUPPORTED_FORMATS })}</span>
          <input
            key={resetFileKey}
            ref={this.setRef}
            type='file'
            multiple
            accept={acceptContentTypes.toArray().join(',')}
            onChange={this.handleChange}
            disabled={disabled}
            style={{ display: 'none' }}
          />
        </label>
      </div>
    );
  }

}
