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

const messages = defineMessages({
  heading: { id: 'column.favourites', defaultMessage: 'Favourites' },
});

const mapStateToProps = state => ({
  statusIds: state.getIn(['status_lists', 'favourites', 'items']),
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

  handleScrollToBottom = () => {
    this.props.dispatch(expandFavouritedStatuses());
  }

  render () {
    const { intl, statusIds, columnId, multiColumn } = this.props;
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
        />

        <StatusList
          trackScroll={!pinned}
          statusIds={statusIds}
          scrollKey={`favourited_statuses-${columnId}`}
          onScrollToBottom={this.handleScrollToBottom}
        />
      </Column>
    );
  }

}
