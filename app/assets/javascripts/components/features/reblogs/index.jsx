import { connect }            from 'react-redux';
import PureRenderMixin        from 'react-addons-pure-render-mixin';
import ImmutablePropTypes     from 'react-immutable-proptypes';
import LoadingIndicator       from '../../components/loading_indicator';
import { fetchReblogs }       from '../../actions/interactions';
import { ScrollContainer }    from 'react-router-scroll';
import AccountContainer       from '../followers/containers/account_container';
import Column                 from '../ui/components/column';
import ColumnBackButton       from '../../components/column_back_button';

const mapStateToProps = (state, props) => ({
  accountIds: state.getIn(['user_lists', 'reblogged_by', Number(props.params.statusId)])
});

const Reblogs = React.createClass({

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this.props.dispatch(fetchReblogs(Number(this.props.params.statusId)));
  },

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.statusId !== this.props.params.statusId && nextProps.params.statusId) {
      this.props.dispatch(fetchReblogs(Number(nextProps.params.statusId)));
    }
  },

  render () {
    const { accountIds } = this.props;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    return (
      <Column>
        <ColumnBackButton />

        <ScrollContainer scrollKey='reblogs'>
          <div className='scrollable'>
            {accountIds.map(id => <AccountContainer key={id} id={id} withNote={false} />)}
          </div>
        </ScrollContainer>
      </Column>
    );
  }

});

export default connect(mapStateToProps)(Reblogs);
