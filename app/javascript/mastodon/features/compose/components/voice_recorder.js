import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import IconButton from '../../../components/icon_button';

const messages = defineMessages({
  start: { id: 'record_voice_start.label', defaultMessage: 'Start recording' },
  stop: { id: 'record_voice_stop.label', defaultMessage: 'Stop recording' },
});

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

class VoiceRecorder extends React.Component {

  static propTypes = {
    onChange: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    recording: false,
  };

  componentWillMount () {
    this.speechRecognition = 'webkitSpeechRecognition' in window ? new webkitSpeechRecognition() : null;

    if (this.speechRecognition) {
      this.speechRecognition.onstart = this.handleRecognitionStart;
      this.speechRecognition.onresult = this.handleRecognitionEnd;
    }
  }

  start = () => {
    this.speechRecognition.start();
  };

  stop = () => {
    this.speechRecognition.stop();
  };

  handleRecognitionStart = () => {
    this.setState({ recording: true });
  };

  handleRecognitionEnd = ({ results }) => {
    this.setState({ recording: false });

    if (results.length > 0) {
      // TODO: We could display all the possible transcripts
      // and allow the user to select which one should be accepted.
      const speechRecognitionResult = results[0];
      const speechRecognitionResultAlternative = speechRecognitionResult[0];
      const { transcript } = speechRecognitionResultAlternative;

      // TODO: Maybe allow the user to append to the current input value?
      this.props.onChange({ target: { value: transcript } });
    }
  };

  render () {
    if (!this.speechRecognition) {
      return null;
    }

    const { intl: { formatMessage } } = this.props;
    const { recording } = this.state;

    const props = recording ?
      { title: formatMessage(messages.stop), icon: 'stop', active: true, onClick: this.stop } :
      { title: formatMessage(messages.start), icon: 'microphone', onClick: this.start };

    return (
      <div className="compose-form__upload-button">
        <IconButton {...props} style={iconStyle} />
      </div>
    );
  }

}

export default injectIntl(VoiceRecorder);
