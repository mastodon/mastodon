import { connect } from 'react-redux';
import Status from '../components/status';
import { makeGetStatus } from '../selectors';
import {
  replyCompose,
  mentionCompose
} from '../actions/compose';
import {
  reblog,
  favourite,
  unreblog,
  unfavourite
} from '../actions/interactions';
import {
  blockAccount,
  muteAccount
} from '../actions/accounts';
import { deleteStatus } from '../actions/statuses';
import { initReport } from '../actions/reports';
import { openModal } from '../actions/modal';
import { createSelector } from 'reselect'
import { isMobile } from '../is_mobile'

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = (state, props) => ({
    status: getStatus(state, props.id),
    me: state.getIn(['meta', 'me']),
    boostModal: state.getIn(['meta', 'boost_modal'])
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch) => ({

  onReply (status, router) {
    dispatch(replyCompose(status, router));
  },

  onModalReblog (status) {
    dispatch(reblog(status));
  },

  onReblog (status, e) {
    if (status.get('reblogged')) {
      dispatch(unreblog(status));
    } else {
      if (e.altKey || !this.boostModal) {
        this.onModalReblog(status);
      } else {
        dispatch(openModal('BOOST', { status, onReblog: this.onModalReblog }));
      }
    }
  },

  onFavourite (status) {
    if (status.get('favourited')) {
      dispatch(unfavourite(status));
    } else {
      dispatch(favourite(status));
    }
  },

  onDelete (status) {
    dispatch(deleteStatus(status.get('id')));
  },

  onMention (account, router) {
    dispatch(mentionCompose(account, router));
  },

  onOpenMedia (media, index) {
    dispatch(openModal('MEDIA', { media, index }));
  },

  onBlock (account) {
    dispatch(blockAccount(account.get('id')));
  },

  onReport (status) {
    dispatch(initReport(status.get('account'), status));
  },

  onMute (account) {
    dispatch(muteAccount(account.get('id')));
  },

});

export default connect(makeMapStateToProps, mapDispatchToProps)(Status);
