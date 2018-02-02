import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import { fetchFavourites } from '../../actions/interactions';
import { ScrollContainer } from 'react-router-scroll-4';
import AccountContainer from '../../containers/account_container';
import Column from '../ui/components/column';
import ColumnBackButton from '../../components/column_back_button';
import ImmutablePureComponent from 'react-immutable-pure-component';

const mapStateToProps = (state, props) => ({
  accountIds: state.getIn(['user_lists', 'favourited_by', props.params.statusId]),
});

@connect(mapStateToProps)
export default class Favourites extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list,
  };

  componentWillMount () {
    this.props.dispatch(fetchFavourites(this.props.params.statusId));
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.statusId !== this.props.params.statusId && nextProps.params.statusId) {
      this.props.dispatch(fetchFavourites(nextProps.params.statusId));
    }
  }

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

}
