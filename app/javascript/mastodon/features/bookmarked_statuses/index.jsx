import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { debounce } from 'lodash';

import { fetchBookmarkedStatuses, expandBookmarkedStatuses } from 'mastodon/actions/bookmarks';
import { addColumn, removeColumn, moveColumn } from 'mastodon/actions/columns';
import ColumnHeader from 'mastodon/components/column_header';
import StatusList from 'mastodon/components/status_list';
import Column from 'mastodon/features/ui/components/column';

const messages = defineMessages({
  heading: { id: 'column.bookmarks', defaultMessage: 'Bookmarks' },
});

const mapStateToProps = state => ({
  statusIds: state.getIn(['status_lists', 'bookmarks', 'items']),
  isLoading: state.getIn(['status_lists', 'bookmarks', 'isLoading'], true),
  hasMore: !!state.getIn(['status_lists', 'bookmarks', 'next']),
});

class Bookmarks extends ImmutablePureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list.isRequired,
    intl: PropTypes.object.isRequired,
    columnId: PropTypes.string,
    multiColumn: PropTypes.bool,
    hasMore: PropTypes.bool,
    isLoading: PropTypes.bool,
  };

  UNSAFE_componentWillMount () {
    this.props.dispatch(fetchBookmarkedStatuses());
  }

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('BOOKMARKS', {}));
    }
  };

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

  setRef = c => {
    this.column = c;
  };

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandBookmarkedStatuses());
  }, 300, { leading: true });

  render () {
    const { intl, statusIds, columnId, multiColumn, hasMore, isLoading } = this.props;
    const pinned = !!columnId;

    const emptyMessage = <FormattedMessage id='empty_column.bookmarked_statuses' defaultMessage="You don't have any bookmarked posts yet. When you bookmark one, it will show up here." />;

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={intl.formatMessage(messages.heading)}>
        <ColumnHeader
          icon='bookmark'
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
          scrollKey={`bookmarked_statuses-${columnId}`}
          hasMore={hasMore}
          isLoading={isLoading}
          onLoadMore={this.handleLoadMore}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
        />

        <Helmet>
          <title>{intl.formatMessage(messages.heading)}</title>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Bookmarks));
