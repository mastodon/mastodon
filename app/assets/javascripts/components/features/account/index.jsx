import { connect }           from 'react-redux';
import PureRenderMixin       from 'react-addons-pure-render-mixin';
import ImmutablePropTypes    from 'react-immutable-proptypes';
import {
  fetchAccount,
  followAccount,
  unfollowAccount,
  blockAccount,
  unblockAccount,
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
  getAccountTimeline,
  getAccount
}                            from '../../selectors';
import StatusList            from '../../components/status_list';
import LoadingIndicator      from '../../components/loading_indicator';
import Immutable             from 'immutable';
import ActionBar             from './components/action_bar';
import Column                from '../ui/components/column';

const mapStateToProps = (state, props) => ({
  account: getAccount(state, Number(props.params.accountId)),
  statuses: getAccountTimeline(state, Number(props.params.accountId)),
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

  handleBlock () {
    if (this.props.account.getIn(['relationship', 'blocking'])) {
      this.props.dispatch(unblockAccount(this.props.account.get('id')));
    } else {
      this.props.dispatch(blockAccount(this.props.account.get('id')));
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
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    return (
      <Column>
        <div style={{ display: 'flex', flexDirection: 'column', 'flex': '0 0 auto', height: '100%' }}>
          <Header account={account} />
          <ActionBar account={account} me={me} onFollow={this.handleFollow} onBlock={this.handleBlock} />
          <StatusList statuses={statuses} me={me} onScrollToBottom={this.handleScrollToBottom} onReply={this.handleReply} onReblog={this.handleReblog} onFavourite={this.handleFavourite} onDelete={this.handleDelete} />
        </div>
      </Column>
    );
  }

});

export default connect(mapStateToProps)(Account);
