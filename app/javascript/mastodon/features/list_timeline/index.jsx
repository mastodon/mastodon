import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import { Helmet } from '@unhead/react/helmet';
import { Link, withRouter } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import DeleteIcon from '@/material-icons/400-24px/delete.svg?react';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import { addColumn, removeColumn, moveColumn } from 'mastodon/actions/columns';
import { fetchList } from 'mastodon/actions/lists';
import { openModal } from 'mastodon/actions/modal';
import { connectListStream } from 'mastodon/actions/streaming';
import { expandListTimeline } from 'mastodon/actions/timelines';
import { Column } from '@/mastodon/components/column';
import { ColumnHeader as LegacyColumnHeader } from '@/mastodon/components/column/header';
import { Icon }  from 'mastodon/components/icon';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';
import StatusListContainer from 'mastodon/features/ui/containers/status_list_container';
import { WithRouterPropTypes } from 'mastodon/utils/react_router';
import { isRedesignEnabled } from '@/mastodon/utils/environment';
import { ColumnHeader, ColumnSettingsMenu } from '@/mastodon/components/column_header';
import { MenuItem, MenuItemLink } from '@/mastodon/components/menu';
import { MultiColumnMenuItems } from '@/mastodon/components/column_header/multicolumn_settings';

const mapStateToProps = (state, props) => ({
  list: state.getIn(['lists', props.params.id]),
  hasUnread: state.getIn(['timelines', `list:${props.params.id}`, 'unread']) > 0,
});

class ListTimeline extends PureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    columnId: PropTypes.string,
    hasUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
    list: PropTypes.oneOfType([ImmutablePropTypes.map, PropTypes.bool]),
    intl: PropTypes.object.isRequired,
    ...WithRouterPropTypes,
  };

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('LIST', { id: this.props.params.id }));
      this.props.history.push('/');
    }
  };

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  };

  componentDidMount () {
    const { dispatch } = this.props;
    const { id } = this.props.params;

    dispatch(fetchList(id));
    dispatch(expandListTimeline(id));

    this.disconnect = dispatch(connectListStream(id));
  }

  componentDidUpdate (prevProps) {
    const { dispatch, params: {id} } = this.props;

    if (id !== prevProps.params.id) {
      if (this.disconnect) {
        this.disconnect();
        this.disconnect = null;
      }

      dispatch(fetchList(id));
      dispatch(expandListTimeline(id));

      this.disconnect = dispatch(connectListStream(id));
    }
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  handleLoadMore = maxId => {
    const { id } = this.props.params;
    this.props.dispatch(expandListTimeline(id, { maxId }));
  };

  handleDeleteClick = () => {
    const { dispatch, columnId } = this.props;
    const { id } = this.props.params;

    dispatch(openModal({ modalType: 'CONFIRM_DELETE_LIST', modalProps: { listId: id, columnId } }));
  };

  render () {
    const { hasUnread, columnId, multiColumn, list } = this.props;
    const { id } = this.props.params;
    const pinned = !!columnId;
    const title  = list ? list.get('title') : id;

    if (typeof list === 'undefined') {
      return (
        <Column>
          <div className='scrollable'>
            <LoadingIndicator />
          </div>
        </Column>
      );
    } else if (list === false) {
      return (
        <BundleColumnError multiColumn={multiColumn} errorType='routing' />
      );
    }

    return (
      <Column bindToDocument={!multiColumn} label={title}>
        {isRedesignEnabled() ? (
          <ColumnHeader
            title={title}
            withBackButton={multiColumn && !pinned && 'auto'}
            extraButtons={
              <ColumnSettingsMenu
                label={
                  <FormattedMessage id='custom_feed.options' defaultMessage='Feed Options' />
                }
              >
                <MenuItemLink as='link' to={`/lists/${id}/edit`}>
                  <FormattedMessage id='custom_feed.edit' defaultMessage='Edit feed' />
                </MenuItemLink>
                <MenuItemLink as='link' to={`/lists/${id}/members`}>
                  <FormattedMessage id='custom_feed.manage_accounts' defaultMessage='Manage members' />
                </MenuItemLink>
                <MenuItem onClick={this.handleDeleteClick}>
                  <FormattedMessage id='custom_feed.delete' defaultMessage='Delete feed' />
                </MenuItem>
                {multiColumn &&
                  <MultiColumnMenuItems
                    withDivider
                    pinned={pinned}
                    onPin={this.handlePin}
                    onMove={this.handleMove}
                  />
                }
              </ColumnSettingsMenu>
            }
          />
        ) : (
          <LegacyColumnHeader
            icon='list-ul'
            iconComponent={ListAltIcon}
            active={hasUnread}
            title={title}
            onPin={this.handlePin}
            onMove={this.handleMove}
            pinned={pinned}
            multiColumn={multiColumn}
            scrollTopOnClick
          >
            <div className='column-settings'>
              <section className='column-header__links'>
                <Link to={`/lists/${id}/edit`} className='text-btn column-header__setting-btn'>
                  <Icon id='pencil' icon={EditIcon} /> <FormattedMessage id='lists.edit' defaultMessage='Edit list' />
                </Link>

                <button type='button' className='text-btn column-header__setting-btn' tabIndex={0} onClick={this.handleDeleteClick}>
                  <Icon id='trash' icon={DeleteIcon} /> <FormattedMessage id='lists.delete' defaultMessage='Delete list' />
                </button>
              </section>
            </div>
          </LegacyColumnHeader>
        )}

        <StatusListContainer
          trackScroll={!pinned}
          scrollKey={`list_timeline-${columnId}`}
          timelineId={`list:${id}`}
          onLoadMore={this.handleLoadMore}
          emptyMessage={isRedesignEnabled
            ? <FormattedMessage id='empty_column.custom_feed' defaultMessage='There is nothing in this custom feed yet. When members of this feed post new statuses, they will appear here.' />
            : <FormattedMessage id='empty_column.list' defaultMessage='There is nothing in this list yet. When members of this list post new statuses, they will appear here.' />
          }
          bindToDocument={!multiColumn}
        />

        <Helmet>
          <title>{title}</title>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default withRouter(connect(mapStateToProps)(ListTimeline));
