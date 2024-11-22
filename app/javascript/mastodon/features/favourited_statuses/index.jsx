import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { debounce } from 'lodash';

import StarIcon from '@/material-icons/400-24px/star-fill.svg?react';
import { addColumn, removeColumn, moveColumn } from 'mastodon/actions/columns';
import { fetchFavouritedStatuses, expandFavouritedStatuses } from 'mastodon/actions/favourites';
import ColumnHeader from 'mastodon/components/column_header';
import StatusList from 'mastodon/components/status_list';
import Column from 'mastodon/features/ui/components/column';
import { getStatusList } from 'mastodon/selectors';

const messages = defineMessages({
  heading: { id: 'column.favourites', defaultMessage: 'Favorites' },
});

const mapStateToProps = state => ({
  statusIds: getStatusList(state, 'favourites'),
  isLoading: state.getIn(['status_lists', 'favourites', 'isLoading'], true),
  hasMore: !!state.getIn(['status_lists', 'favourites', 'next']),
});

class Favourites extends ImmutablePureComponent {

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
    this.props.dispatch(fetchFavouritedStatuses());
  }

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('FAVOURITES', {}));
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
    this.props.dispatch(expandFavouritedStatuses());
  }, 300, { leading: true });

  render () {
    const { intl, statusIds, columnId, multiColumn, hasMore, isLoading } = this.props;
    const pinned = !!columnId;

    const emptyMessage = <FormattedMessage id='empty_column.favourited_statuses' defaultMessage="You don't have any favorite posts yet. When you favorite one, it will show up here." />;

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={intl.formatMessage(messages.heading)}>
        <ColumnHeader
          icon='star'
          iconComponent={StarIcon}
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

export default connect(mapStateToProps)(injectIntl(Favourites));
