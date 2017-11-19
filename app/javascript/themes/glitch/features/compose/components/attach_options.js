//  Package imports  //
import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { injectIntl, defineMessages } from 'react-intl';

//  Our imports  //
import ComposeDropdown from './dropdown';
import { uploadCompose } from 'themes/glitch/actions/compose';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { openModal } from 'themes/glitch/actions/modal';

const messages = defineMessages({
  upload :
    { id: 'compose.attach.upload', defaultMessage: 'Upload a file' },
  doodle :
    { id: 'compose.attach.doodle', defaultMessage: 'Draw something' },
  attach :
    { id: 'compose.attach', defaultMessage: 'Attach...' },
});

const mapStateToProps = state => ({
  // This horrible expression is copied from vanilla upload_button_container
  disabled: state.getIn(['compose', 'is_uploading']) || (state.getIn(['compose', 'media_attachments']).size > 3 || state.getIn(['compose', 'media_attachments']).some(m => m.get('type') === 'video')),
  resetFileKey: state.getIn(['compose', 'resetFileKey']),
  acceptContentTypes: state.getIn(['media_attachments', 'accept_content_types']),
});

const mapDispatchToProps = dispatch => ({
  onSelectFile (files) {
    dispatch(uploadCompose(files));
  },
  onOpenDoodle () {
    dispatch(openModal('DOODLE', { noEsc: true }));
  },
});

@injectIntl
@connect(mapStateToProps, mapDispatchToProps)
export default class ComposeAttachOptions extends ImmutablePureComponent {

  static propTypes = {
    intl     : PropTypes.object.isRequired,
    resetFileKey: PropTypes.number,
    acceptContentTypes: ImmutablePropTypes.listOf(PropTypes.string).isRequired,
    disabled: PropTypes.bool,
    onSelectFile: PropTypes.func.isRequired,
    onOpenDoodle: PropTypes.func.isRequired,
  };

  handleItemClick = bt => {
    if (bt === 'upload') {
      this.fileElement.click();
    }

    if (bt === 'doodle') {
      this.props.onOpenDoodle();
    }

    this.dropdown.setState({ open: false });
  };

  handleFileChange = (e) => {
    if (e.target.files.length > 0) {
      this.props.onSelectFile(e.target.files);
    }
  }

  setFileRef = (c) => {
    this.fileElement = c;
  }

  setDropdownRef = (c) => {
    this.dropdown = c;
  }

  render () {
    const { intl, resetFileKey, disabled, acceptContentTypes } = this.props;

    const options = [
      { icon: 'cloud-upload', text: messages.upload, name: 'upload' },
      { icon: 'paint-brush', text: messages.doodle, name: 'doodle' },
    ];

    const optionElems = options.map((item) => {
      const hdl = () => this.handleItemClick(item.name);
      return (
        <div
          role='button'
          tabIndex='0'
          key={item.name}
          onClick={hdl}
          className='privacy-dropdown__option'
        >
          <div className='privacy-dropdown__option__icon'>
            <i className={`fa fa-fw fa-${item.icon}`} />
          </div>

          <div className='privacy-dropdown__option__content'>
            <strong>{intl.formatMessage(item.text)}</strong>
          </div>
        </div>
      );
    });

    return (
      <div>
        <ComposeDropdown
          title={intl.formatMessage(messages.attach)}
          icon='paperclip'
          disabled={disabled}
          ref={this.setDropdownRef}
        >
          {optionElems}
        </ComposeDropdown>
        <input
          key={resetFileKey}
          ref={this.setFileRef}
          type='file'
          multiple={false}
          accept={acceptContentTypes.toArray().join(',')}
          onChange={this.handleFileChange}
          disabled={disabled}
          style={{ display: 'none' }}
        />
      </div>
    );
  }

}
