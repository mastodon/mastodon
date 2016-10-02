import { connect }           from 'react-redux';
import PureRenderMixin       from 'react-addons-pure-render-mixin';
import ImmutablePropTypes    from 'react-immutable-proptypes';
import {
  fetchAccount,
  followAccount,
  unfollowAccount,
  fetchAccountTimeline,
  expandAccountTimeline
}                            from '../../actions/accounts';
import { deleteStatus }      from '../../actions/statuses';
import { replyCompose }      from '../../actions/compose';
import {
  favourite,
  reblog,
  unreblog,
  unfavourite
}                            from '../../actions/interactions';
import Header                from './components/header';
import {
  selectStatus,
  selectAccount
}                            from '../../reducers/timelines';
import StatusList            from '../../components/status_list';
import Immutable             from 'immutable';
import ActionBar             from './components/action_bar';

function selectStatuses(state, accountId) {
  return state.getIn(['timelines', 'accounts_timelines', accountId], Immutable.List()).map(id => selectStatus(state, id)).filterNot(status => status === null);
};

const mapStateToProps = (state, props) => ({
  account: selectAccount(state, Number(props.params.accountId)),
  statuses: selectStatuses(state, Number(props.params.accountId)),
  me: state.getIn(['timelines', 'me'])
});

const Account = React.createClass({

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    account: ImmutablePropTypes.map,
    statuses: ImmutablePropTypes.list
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this.props.dispatch(fetchAccount(Number(this.props.params.accountId)));
    this.props.dispatch(fetchAccountTimeline(Number(this.props.params.accountId)));
  },

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.accountId !== this.props.params.accountId && nextProps.params.accountId) {
      this.props.dispatch(fetchAccount(Number(nextProps.params.accountId)));
      this.props.dispatch(fetchAccountTimeline(Number(nextProps.params.accountId)));
    }
  },

  handleFollow () {
    if (this.props.account.getIn(['relationship', 'following'])) {
      this.props.dispatch(unfollowAccount(this.props.account.get('id')));
    } else {
      this.props.dispatch(followAccount(this.props.account.get('id')));
    }
  },

  handleReply (status) {
    this.props.dispatch(replyCompose(status));
  },

  handleReblog (status) {
    if (status.get('reblogged')) {
      this.props.dispatch(unreblog(status));
    } else {
      this.props.dispatch(reblog(status));
    }
  },

  handleFavourite (status) {
    if (status.get('favourited')) {
      this.props.dispatch(unfavourite(status));
    } else {
      this.props.dispatch(favourite(status));
    }
  },

  handleDelete (status) {
    this.props.dispatch(deleteStatus(status.get('id')));
  },

  handleScrollToBottom () {
    this.props.dispatch(expandAccountTimeline(this.props.account.get('id')));
  },

  render () {
    const { account, statuses, me } = this.props;

    if (account === null) {
      return <div>Loading {this.props.params.accountId}...</div>;
    }

    return (
      <div style={{ display: 'flex', flexDirection: 'column', 'flex': '0 0 auto', height: '100%' }}>
        <Header account={account} />
        <ActionBar account={account} me={me} onFollow={this.handleFollow} onUnfollow={this.handleUnfollow} />
        <StatusList statuses={statuses} me={me} onScrollToBottom={this.handleScrollToBottom} onReply={this.handleReply} onReblog={this.handleReblog} onFavourite={this.handleFavourite} />
      </div>
    );
  }

});

export default connect(mapStateToProps)(Account);
