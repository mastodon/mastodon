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
import { mentionCompose }    from '../../actions/compose';
import Header                from './components/header';
import {
  getAccountTimeline,
  makeGetAccount
}                            from '../../selectors';
import LoadingIndicator      from '../../components/loading_indicator';
import ActionBar             from './components/action_bar';
import Column                from '../ui/components/column';
import ColumnBackButton      from '../../components/column_back_button';
import { isMobile } from '../../is_mobile'

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, props) => ({
    account: getAccount(state, Number(props.params.accountId)),
    me: state.getIn(['meta', 'me'])
  });

  return mapStateToProps;
};

const Account = React.createClass({

  contextTypes: {
    router: React.PropTypes.object
  },

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    account: ImmutablePropTypes.map,
    me: React.PropTypes.number.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this.props.dispatch(fetchAccount(Number(this.props.params.accountId)));
  },

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.accountId !== this.props.params.accountId && nextProps.params.accountId) {
      this.props.dispatch(fetchAccount(Number(nextProps.params.accountId)));
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

  handleMention () {
    this.props.dispatch(mentionCompose(this.props.account));
    if (isMobile(window.innerWidth)) {
      this.context.router.push('/statuses/new');
    }
  },

  render () {
    const { account, me } = this.props;

    if (account === null) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    return (
      <Column>
        <ColumnBackButton />
        <Header account={account} me={me} onFollow={this.handleFollow} />
        <ActionBar account={account} me={me} onBlock={this.handleBlock} onMention={this.handleMention} />

        {this.props.children}
      </Column>
    );
  }

});

export default connect(makeMapStateToProps)(Account);
