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
import { blockAccount } from '../actions/accounts';
import { deleteStatus } from '../actions/statuses';
import { openMedia } from '../actions/modal';
import { createSelector } from 'reselect'
import { isMobile } from '../is_mobile'

const mapStateToProps = (state, props) => ({
  statusBase: state.getIn(['statuses', props.id]),
  me: state.getIn(['meta', 'me'])
});

const makeMapStateToPropsInner = () => {
  const getStatus = (() => {
    return createSelector(
      [
        (_, base)     => base,
        (state, base) => (base ? state.getIn(['accounts', base.get('account')]) : null),
        (state, base) => (base ? state.getIn(['statuses', base.get('reblog')], null) : null)
      ],

      (base, account, reblog) => (base ? base.set('account', account).set('reblog', reblog) : null)
    );
  })();

  const mapStateToProps = (state, { statusBase }) => ({
    status: getStatus(state, statusBase)
  });

  return mapStateToProps;
};

const makeMapStateToPropsLast = () => {
  const getStatus = (() => {
    return createSelector(
      [
        (_, status)     => status,
        (state, status) => (status ? state.getIn(['accounts', status.getIn(['reblog', 'account'])], null) : null)
      ],

      (status, reblogAccount) => (status && status.get('reblog') ? status.setIn(['reblog', 'account'], reblogAccount) : status)
    );
  })();

  const mapStateToProps = (state, { status }) => ({
    status: getStatus(state, status)
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch) => ({

  onReply (status, router) {
    dispatch(replyCompose(status, router));
  },

  onReblog (status) {
    if (status.get('reblogged')) {
      dispatch(unreblog(status));
    } else {
      dispatch(reblog(status));
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
    dispatch(openMedia(media, index));
  },

  onBlock (account) {
    dispatch(blockAccount(account.get('id')));
  }

});

export default connect(mapStateToProps, mapDispatchToProps)(
  connect(makeMapStateToPropsInner)(
    connect(makeMapStateToPropsLast)(Status)
  )
);
