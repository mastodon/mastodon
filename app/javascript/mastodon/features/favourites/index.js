import React from 'react';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import { fetchFavourites } from '../../actions/interactions';
import { FormattedMessage } from 'react-intl';
import AccountContainer from '../../containers/account_container';
import Column from '../ui/components/column';
import ColumnBackButton from '../../components/column_back_button';
import ScrollableList from '../../components/scrollable_list';

const mapStateToProps = (state, props) => ({
  accountIds: state.getIn(['user_lists', 'favourited_by', props.params.statusId]),
});

export default @connect(mapStateToProps)
class Favourites extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
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
    const { shouldUpdateScroll, accountIds } = this.props;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='empty_column.favourites' defaultMessage='No one has favourited this toot yet. When someone does, they will show up here.' />;

    return (
      <Column>
        <ColumnBackButton />

        <ScrollableList
          scrollKey='favourites'
          shouldUpdateScroll={shouldUpdateScroll}
          emptyMessage={emptyMessage}
        >
          {accountIds.map(id =>
            <AccountContainer key={id} id={id} withNote={false} />
          )}
        </ScrollableList>
      </Column>
    );
  }

}
