import PropTypes from 'prop-types';
import React from 'react';

import { defineMessages, injectIntl } from 'react-intl';

import { connect } from 'react-redux';

import DeleteIcon from '@/material-icons/400-24px/delete.svg?react';
import MotionPhotosOnIcon from '@/material-icons/400-24px/motion_photos_on.svg?react';
import { Icon }  from 'mastodon/components/icon';
import IconButton from 'mastodon/components/icon_button';

import { deleteCircle } from '../../../actions/circles';
import { openModal } from '../../../actions/modal';

const messages = defineMessages({
  deleteMessage: { id: 'confirmations.delete_circle.message', defaultMessage: 'Are you sure you want to permanently delete this circle?' },
  deleteConfirm: { id: 'confirmations.delete_circle.confirm', defaultMessage: 'Delete' },
});

const MapStateToProps = (state, { circleId }) => ({
  circle: state.get('circles').get(circleId),
});

class Circle extends React.PureComponent {

  static propTypes = {
    id: PropTypes.string.isRequired,
    text: PropTypes.string.isRequired,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleEditClick = () => {
    this.props.dispatch(openModal({ modalType: 'CIRCLE_EDITOR', modalProps: { circleId: this.props.id }}));
  };

  handleDeleteClick = () => {
    const { dispatch, intl } = this.props;
    const { id } = this.props;

    dispatch(openModal({ modalType: 'CONFIRM', modalProps: {
      message: intl.formatMessage(messages.deleteMessage),
      confirm: intl.formatMessage(messages.deleteConfirm),
      onConfirm: () => {
        dispatch(deleteCircle(id));
      },
    }}));
  };

  render() {
    const { text, intl } = this.props;

    return (
      <div className='circle-link'>
        <button className='circle-edit-button' onClick={this.handleEditClick}>
          <Icon id='motion_photos_on' icon='motion_photos_on' iconComponent={MotionPhotosOnIcon} className='column-link__icon' fixedWidth />
          {text}
        </button>
        <IconButton icon='delete' iconComponent={DeleteIcon} className='circle-delete-button' title={intl.formatMessage(messages.deleteConfirm)} onClick={this.handleDeleteClick} />
      </div>
    );
  }

}
export default connect(MapStateToProps)(injectIntl(Circle));
