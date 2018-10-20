import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import ColumnSettingsContainer from './containers/column_settings_container';
import { expandHashtagTimeline, clearTimeline } from '../../actions/timelines';
import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import { FormattedMessage } from 'react-intl';
import { connectHashtagStream } from '../../actions/streaming';

const mapStateToProps = (state, props) => ({
  hasUnread: state.getIn(['timelines', `hashtag:${props.params.id}`, 'unread']) > 0,
});

export default @connect(mapStateToProps)
class HashtagTimeline extends React.PureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    columnId: PropTypes.string,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
    hasUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
  };

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('HASHTAG', { id: this.props.params.id }));
    }
  }

  title = () => {
    let title = [this.props.params.id];
    if (this.additionalFor('any')) {
      title.push(<FormattedMessage id='hashtag.column_header.tag_mode.any'  values={{ additional: this.additionalFor('any') }} defaultMessage=' or {additional}' />);
    }
    if (this.additionalFor('all')) {
      title.push(<FormattedMessage id='hashtag.column_header.tag_mode.all'  values={{ additional: this.additionalFor('all') }} defaultMessage=' and {additional}' />);
    }
    if (this.additionalFor('none')) {
      title.push(<FormattedMessage id='hashtag.column_header.tag_mode.none' values={{ additional: this.additionalFor('none') }} defaultMessage=' without {additional}' />);
    }
    return title;
  }

  additionalFor = (mode) => {
    const { tags } = this.props.params;

    if ((tags[mode] || []).length > 0) {
      return tags[mode].map((tag) => {
        return tag.value;
      }).join('/');
    } else {
      return '';
    }
  }

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  _subscribe (dispatch, id) {
    this.disconnect = dispatch(connectHashtagStream(id));
  }

  _unsubscribe () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  componentDidMount () {
    const { dispatch } = this.props;
    const { id, tags } = this.props.params;

    dispatch(expandHashtagTimeline(id, { tags }));
    this._subscribe(dispatch, id);
  }

  componentWillReceiveProps (nextProps) {
    const { id, tags } = nextProps.params;
    if (
      id !== this.props.params.id ||
      tags !== this.props.params.tags
    ) {
      if (id !== this.props.params.id) {
        this._unsubscribe();
        this._subscribe(this.props.dispatch, nextProps.params.id);
      } else {
        this.props.dispatch(clearTimeline(`hashtag:${id}`));
      }
      this.props.dispatch(expandHashtagTimeline(id, { tags }));
    }
  }

  componentWillUnmount () {
    this._unsubscribe();
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = maxId => {
    const { id, tags } = this.props.params;
    this.props.dispatch(expandHashtagTimeline(id, { maxId, tags }));
  }

  render () {
    const { shouldUpdateScroll, hasUnread, columnId, multiColumn } = this.props;
    const { id } = this.props.params;
    const pinned = !!columnId;

    return (
      <Column ref={this.setRef} label={`#${id}`}>
        <ColumnHeader
          icon='hashtag'
          active={hasUnread}
          title={this.title()}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
          showBackButton
        >
          {columnId && <ColumnSettingsContainer columnId={columnId} />}
        </ColumnHeader>

        <StatusListContainer
          trackScroll={!pinned}
          scrollKey={`hashtag_timeline-${columnId}`}
          timelineId={`hashtag:${id}`}
          onLoadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.hashtag' defaultMessage='There is nothing in this hashtag yet.' />}
          shouldUpdateScroll={shouldUpdateScroll}
        />
      </Column>
    );
  }

}
