import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { injectIntl, FormattedMessage } from 'react-intl';
import Button from '../../../components/button';
import { closeModal } from '../../../actions/modal';

const makeMapStateToProps = () => {
  const mapStateToProps = state => ({
    media: state.getIn(['compose', 'media_attachments']),
  });

  return mapStateToProps;
};

const mapDispatchToProps = dispatch => {
  return {
    onClose() {
      dispatch(closeModal());
    },
  };
};

// This modal is displayed when a user attempts to submit a post with an image
// or video file that has no alt text.
export default @connect(makeMapStateToProps, mapDispatchToProps)
@injectIntl
class AltTextWarningModal extends React.PureComponent {

  static propTypes = {
    onClose: PropTypes.func.isRequired,
    onSubmitCompose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount() {
    this.button.focus();
  }

  handleClick = () => {
    this.props.onSubmitCompose();
    this.props.onClose();
  }

  handleCancel = () => {
    this.props.onClose();
  }

  setRef = (c) => {
    this.button = c;
  }

  render () {
    return (
      <div className='modal-root__modal alt-text-warning-modal'>
        <div className='alt-text-warning-modal__container'>
          <h4 className='alt-text-warning-modal__title'>
            <FormattedMessage
              id='compose_form.alt_text_warning.header'
              defaultMessage='Your attachments are missing a description!'
            />
          </h4>
          <p>
            <FormattedMessage
              id='compose_form.alt_text_warning.message'
              defaultMessage="Descriptions are for users with visual or audio impairments that prevent them from seeing or hearing an image, video, or audio file. It's recommended that you provide a description for all attached media files so everyone can enjoy using Mastodon."
            />
          </p>
        </div>

        <div className='alt-text-warning-modal__action-bar'>
          <Button onClick={this.handleCancel}>
            <FormattedMessage id='compose_form.alt_text_warning.go_back' defaultMessage='Go back' />
          </Button>
          <Button onClick={this.handleClick} ref={this.setRef} className='confirmation-modal__cancel-button'>
            <FormattedMessage id='compose_form.alt_text_warning.publish_anyway' defaultMessage='Publish anyway' />
          </Button>
        </div>
      </div>
    );
  }

}
