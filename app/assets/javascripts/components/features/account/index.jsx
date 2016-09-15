import { connect }                                      from 'react-redux';
import PureRenderMixin                                  from 'react-addons-pure-render-mixin';
import ImmutablePropTypes                               from 'react-immutable-proptypes';
import { fetchAccount, followAccount, unfollowAccount } from '../../actions/accounts';
import Button                                           from '../../components/button';

function selectAccount(state, id) {
  return state.getIn(['timelines', 'accounts', id], null);
}

const mapStateToProps = (state, props) => ({
  account: selectAccount(state, Number(props.params.accountId))
});

const Account = React.createClass({

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    account: ImmutablePropTypes.map
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this.props.dispatch(fetchAccount(this.props.params.accountId));
  },

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.accountId !== this.props.params.accountId && nextProps.params.accountId) {
      this.props.dispatch(fetchAccount(nextProps.params.accountId));
    }
  },

  handleFollowClick () {
    this.props.dispatch(followAccount(this.props.account.get('id')));
  },

  handleUnfollowClick () {
    this.props.dispatch(unfollowAccount(this.props.account.get('id')));
  },

  render () {
    const { account } = this.props;
    let action;

    if (account === null) {
      return <div>Loading {this.props.params.accountId}...</div>;
    }

    if (account.get('following')) {
      action = <Button text='Unfollow' onClick={this.handleUnfollowClick} />;
    } else {
      action = <Button text='Follow' onClick={this.handleFollowClick} />
    }

    return (
      <div>
        <p>
          {account.get('display_name')}
          {account.get('acct')}
        </p>

        {account.get('url')}

        <p>{account.get('note')}</p>

        {account.get('followers_count')} followers<br />
        {account.get('following_count')} following<br />
        {account.get('statuses_count')} posts

        <p>{action}</p>
      </div>
    );
  }

});

export default connect(mapStateToProps)(Account);
