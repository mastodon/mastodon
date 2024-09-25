import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import PhotoLibraryIcon from '@/material-icons/400-20px/photo_library.svg?react';
import { IconButton } from 'mastodon/components/icon_button';

const messages = defineMessages({
  upload: { id: 'upload_button.label', defaultMessage: 'Add images, a video or an audio file' },
});

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

class UploadButton extends ImmutablePureComponent {

  static propTypes = {
    disabled: PropTypes.bool,
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
  };

  handleClick = () => {
    this.fileElement.click();
  };

  setRef = (c) => {
    this.fileElement = c;
  };

  render () {
    const { intl, resetFileKey, disabled, acceptContentTypes } = this.props;

    const message = intl.formatMessage(messages.upload);

    return (
      <div className='compose-form__upload-button'>
        <IconButton icon='paperclip' iconComponent={PhotoLibraryIcon} title={message} disabled={disabled} onClick={this.handleClick} className='compose-form__upload-button-icon' size={18} inverted style={iconStyle} />
        <label>
          <span style={{ display: 'none' }}>{message}</span>
          <input
            key={resetFileKey}
            ref={this.setRef}
            type='file'
            name='file-upload-input'
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

export default connect(makeMapStateToProps)(injectIntl(UploadButton));
