import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { fetchFavouritedStatuses, expandFavouritedStatuses } from '../../actions/favourites';
import Column from '../ui/components/column';
import ColumnHeader from '../../components/column_header';
import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import StatusList from '../../components/status_list';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { debounce } from 'lodash';

const messages = defineMessages({
  heading: { id: 'column.favourites', defaultMessage: 'Favourites' },
});

const mapStateToProps = state => ({
  statusIds: state.getIn(['status_lists', 'favourites', 'items']),
  isLoading: state.getIn(['status_lists', 'favourites', 'isLoading'], true),
  hasMore: !!state.getIn(['status_lists', 'favourites', 'next']),
});

@connect(mapStateToProps)
@injectIntl
export default class Favourites extends ImmutablePureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list.isRequired,
    intl: PropTypes.object.isRequired,
    columnId: PropTypes.string,
    multiColumn: PropTypes.bool,
    hasMore: PropTypes.bool,
    isLoading: PropTypes.bool,
  };

  componentWillMount () {
    this.props.dispatch(fetchFavouritedStatuses());
  }

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('FAVOURITES', {}));
    }
  }

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandFavouritedStatuses());
  }, 300, { leading: true })

  render () {
    const { intl, statusIds, columnId, multiColumn, hasMore, isLoading } = this.props;
    const pinned = !!columnId;

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='star'
          title={intl.formatMessage(messages.heading)}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
          showBackButton
        />

        <StatusList
          trackScroll={!pinned}
          statusIds={statusIds}
          scrollKey={`favourited_statuses-${columnId}`}
          hasMore={hasMore}
          isLoading={isLoading}
          onLoadMore={this.handleLoadMore}
        />
      </Column>
    );
  }

}
