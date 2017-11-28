import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import { FormattedMessage } from 'react-intl';
import { connectListStream } from '../../actions/streaming';
import { refreshListTimeline, expandListTimeline } from '../../actions/timelines';
import { fetchList } from '../../actions/lists';

const mapStateToProps = (state, props) => ({
  list: state.getIn(['lists', props.params.id]),
  hasUnread: state.getIn(['timelines', `list:${props.params.id}`, 'unread']) > 0,
});

@connect(mapStateToProps)
export default class ListTimeline extends React.PureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    columnId: PropTypes.string,
    hasUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
    list: ImmutablePropTypes.map,
  };

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('LIST', { id: this.props.params.id }));
    }
  }

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  componentDidMount () {
    const { dispatch } = this.props;
    const { id } = this.props.params;

    dispatch(fetchList(id));
    dispatch(refreshListTimeline(id));

    this.disconnect = dispatch(connectListStream(id));
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = () => {
    const { id } = this.props.params;
    this.props.dispatch(expandListTimeline(id));
  }

  render () {
    const { hasUnread, columnId, multiColumn, list } = this.props;
    const { id } = this.props.params;
    const pinned = !!columnId;
    const title  = list ? list.get('title') : id;

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='bars'
          active={hasUnread}
          title={title}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
        />

        <StatusListContainer
          trackScroll={!pinned}
          scrollKey={`list_timeline-${columnId}`}
          timelineId={`list:${id}`}
          loadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.list' defaultMessage='There is nothing in this list yet.' />}
        />
      </Column>
    );
  }

}
