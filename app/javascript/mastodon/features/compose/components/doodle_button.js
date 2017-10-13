import React from 'react';
import IconButton from '../../../components/icon_button';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  doodle: { id: 'doodle_button.label', defaultMessage: 'Add a drawing' },
});

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

@injectIntl
export default class UploadButton extends ImmutablePureComponent {

  static propTypes = {
    disabled: PropTypes.bool,
    onOpenCanvas: PropTypes.func.isRequired,
    style: PropTypes.object,
    intl: PropTypes.object.isRequired,
  };

  handleClick = () => {
    this.props.onOpenCanvas();
  }

  render () {

    const { intl, disabled } = this.props;

    return (
      <div className='compose-form__upload-button'>
        <IconButton icon='pencil' title={intl.formatMessage(messages.doodle)} disabled={disabled} onClick={this.handleClick} className='compose-form__upload-button-icon' size={18} inverted style={iconStyle} />
      </div>
    );
  }

}
