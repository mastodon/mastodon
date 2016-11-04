import { connect }            from 'react-redux';
import PureRenderMixin        from 'react-addons-pure-render-mixin';
import ImmutablePropTypes     from 'react-immutable-proptypes';
import LoadingIndicator       from '../../components/loading_indicator';
import { fetchFollowing }     from '../../actions/accounts';
import { ScrollContainer }    from 'react-router-scroll';
import AccountContainer       from '../followers/containers/account_container';

const mapStateToProps = (state, props) => ({
  accountIds: state.getIn(['user_lists', 'following', Number(props.params.accountId)])
});

const Following = React.createClass({

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this.props.dispatch(fetchFollowing(Number(this.props.params.accountId)));
  },

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.accountId !== this.props.params.accountId && nextProps.params.accountId) {
      this.props.dispatch(fetchFollowing(Number(nextProps.params.accountId)));
    }
  },

  render () {
    const { accountIds } = this.props;

    if (!accountIds) {
      return <LoadingIndicator />;
    }

    return (
      <ScrollContainer scrollKey='following'>
        <div className='scrollable'>
          {accountIds.map(id => <AccountContainer key={id} id={id} withNote={false} />)}
        </div>
      </ScrollContainer>
    );
  }

});

export default connect(mapStateToProps)(Following);
