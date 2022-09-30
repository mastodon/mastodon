import React from 'react';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import GroupHeader from '../components/group_header';
import { groupCompose } from 'mastodon/actions/compose';
import { openModal } from 'mastodon/actions/modal';
import { joinGroup, leaveGroup, deleteGroup } from 'mastodon/actions/groups';
import { unfollowModal } from 'mastodon/initial_state';

const messages = defineMessages({
  groupPostConfirm: { id: 'confirmations.group_post.confirm', defaultMessage: 'Write group post' },
  groupPostMessage: { id: 'confirmations.group_post.message', defaultMessage: 'Writing a group post will overwrite the message you are currently composing. Are you sure you want to proceed?' },
  leaveConfirm: { id: 'confirmations.leave.confirm', defaultMessage: 'Leave' },
  deleteGroupConfirm: { id: 'confirmations.delete_group.confirm', defaultMessage: 'Delete' },
});

const mapStateToProps = (state, props) => ({
  relationship: state.getIn(['group_relationships', props?.group?.get('id')]),
});

const mapDispatchToProps = (dispatch, { intl, group }) => ({

  onWritePost(router) {
    dispatch((_, getState) => {
      let state = getState();

      if (state.getIn(['compose', 'in_reply_to'])) {
        dispatch(openModal('CONFIRM', {
          message: intl.formatMessage(messages.groupPostMessage),
          confirm: intl.formatMessage(messages.groupPostConfirm),
          onConfirm: () => dispatch(groupCompose(group.get('id'), router)),
        }));
      } else {
        dispatch(groupCompose(group.get('id'), router));
      }

    });
  },

  onJoinLeave(relationship) {
    if (relationship.get('member') || relationship.get('requested')) {
      if (unfollowModal) {
        dispatch(openModal('CONFIRM', {
          message: <FormattedMessage id='confirmations.leave.message' defaultMessage='Are you sure you want to leave this group?' />,
          confirm: intl.formatMessage(messages.leaveConfirm),
          onConfirm: () => dispatch(leaveGroup(group.get('id'))),
        }));
      } else {
        dispatch(leaveGroup(group.get('id')));
      }
    } else {
      dispatch(joinGroup(group.get('id')));
    }

  },

  onDeleteGroup() {
    dispatch(openModal('CONFIRM', {
      message: (
        <React.Fragment>
          <FormattedMessage id='confirmations.delete_group.message' defaultMessage='Are you sure you want to delete this group?' /> <strong><FormattedMessage id='confirmations.delete_group.emphasis' defaultMessage='This will irreversibly delete all posts made in this group.' /></strong>
        </React.Fragment>
      ),
      confirm: intl.formatMessage(messages.deleteGroupConfirm),
      onConfirm: () => dispatch(deleteGroup(group.get('id'))),
    }));
  },

});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(GroupHeader));
