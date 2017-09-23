import React from 'react';
import IconButton from '../../../components/icon_button';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  enquete: { id: 'enquete_button.label', defaultMessage: 'Create enquete' },
});

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

@injectIntl
export default class EnqueteButton extends ImmutablePureComponent {

  static propTypes = {
    active: PropTypes.bool.isRequired,
    style: PropTypes.object,
    intl: PropTypes.object.isRequired,
    onClick: PropTypes.func.isRequired,
  };

  handleClick = (e) => {
    e.preventDefault();
    this.props.onClick();
  }

  render () {
    const { intl } = this.props;

    return (
      <div className='compose-form__enquete-button'>
        <IconButton active={this.props.active} icon='align-left' title={intl.formatMessage(messages.enquete)} onClick={this.handleClick} className='compose-form__enquete-button-icon' size={18} inverted style={iconStyle} />
      </div>
    );
  }

}