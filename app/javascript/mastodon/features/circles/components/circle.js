import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import Icon from '../../../components/icon';
import { openModal } from '../../../actions/modal';
import { deleteCircle } from '../../../actions/circles';

const messages = defineMessages({
  deleteMessage: { id: 'confirmations.delete_circle.message', defaultMessage: 'Are you sure you want to permanently delete this circle?' },
  deleteConfirm: { id: 'confirmations.delete_circle.confirm', defaultMessage: 'Delete' },
});

export default @connect()
@injectIntl
class Circle extends React.PureComponent {

  static propTypes = {
    id: PropTypes.string.isRequired,
    text: PropTypes.string.isRequired,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleEditClick = () => {
    this.props.dispatch(openModal('CIRCLE_EDITOR', { circleId: this.props.id }));
  }

  handleDeleteClick = () => {
    const { dispatch, intl } = this.props;
    const { id } = this.props;

    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.deleteMessage),
      confirm: intl.formatMessage(messages.deleteConfirm),
      onConfirm: () => {
        dispatch(deleteCircle(id));
      },
    }));
  }

  render() {
    const { text, intl } = this.props;

    return (
      <div className='circle-link'>
        <button className='circle-edit-button' onClick={this.handleEditClick}>
          <Icon id='user-circle' className='column-link__icon' fixedWidth />
          {text}
        </button>
        <button className='circle-delete-button' title={intl.formatMessage(messages.deleteConfirm)} onClick={this.handleDeleteClick}>
          <Icon id='trash' className='column-link__icon' fixedWidth />
        </button>
      </div>
    );
  }

}
