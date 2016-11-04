import { connect }            from 'react-redux';
import PureRenderMixin        from 'react-addons-pure-render-mixin';
import ImmutablePropTypes     from 'react-immutable-proptypes';
import LoadingIndicator       from '../../components/loading_indicator';
import { fetchFavourites }    from '../../actions/interactions';
import { ScrollContainer }    from 'react-router-scroll';
import AccountContainer       from '../followers/containers/account_container';
import Column                 from '../ui/components/column';
import ColumnBackButton       from '../../components/column_back_button';

const mapStateToProps = (state, props) => ({
  accountIds: state.getIn(['user_lists', 'favourited_by', Number(props.params.statusId)])
});

const Favourites = React.createClass({

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this.props.dispatch(fetchFavourites(Number(this.props.params.statusId)));
  },

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.statusId !== this.props.params.statusId && nextProps.params.statusId) {
      this.props.dispatch(fetchFavourites(Number(nextProps.params.statusId)));
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

        <ScrollContainer scrollKey='favourites'>
          <div className='scrollable'>
            {accountIds.map(id => <AccountContainer key={id} id={id} withNote={false} />)}
          </div>
        </ScrollContainer>
      </Column>
    );
  }

});

export default connect(mapStateToProps)(Favourites);
