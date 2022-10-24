import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from 'mastodon/components/column';
import ColumnBackButton from 'mastodon/components/column_back_button';
import ColumnHeader from 'mastodon/components/column_header';
import { addColumn, removeColumn, moveColumn, changeColumnParams } from 'mastodon/actions/columns';
import { changeSetting } from 'mastodon/actions/settings';
import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';
import { connectGroupStream } from 'mastodon/actions/streaming';
import { expandGroupTimeline } from 'mastodon/actions/timelines';
import { fetchGroup } from 'mastodon/actions/groups';
import MissingIndicator from 'mastodon/components/missing_indicator';
import LoadingIndicator from 'mastodon/components/loading_indicator';
import classNames from 'classnames';
import Icon from 'mastodon/components/icon';
import GroupHeaderContainer from './containers/group_header_container';

const messages = defineMessages({
  show_group_info: { id: 'groups.show_info', defaultMessage: 'Show group information' },
  hide_group_info: { id: 'groups.hide_info', defaultMessage: 'Hide group information' },
});

const mapStateToProps = (state, props) => {
  const uuid = props.columnId;
  const columnSettings = state.getIn(['settings', 'columns']).find(c => c.get('uuid') === uuid);
  const showGroupInfo = columnSettings ? columnSettings.getIn(['params', 'showGroupInfo'], true) : state.getIn(['settings', 'groups', props.params.id, 'showGroupInfo'], true);

  return ({
    group: state.getIn(['groups', props.params.id]),
    hasUnread: state.getIn(['timelines', `group:${props.params.id}`, 'unread']) > 0,
    showGroupInfo
  });
};

export default @connect(mapStateToProps)
@injectIntl
class GroupTimeline extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
    identity: PropTypes.object,
  };

  static propTypes = {
    params: PropTypes.shape({
      id: PropTypes.string,
    }).isRequired,
    dispatch: PropTypes.func.isRequired,
    columnId: PropTypes.string,
    hasUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
    group: PropTypes.oneOfType([ImmutablePropTypes.map, PropTypes.bool]),
    showGroupInfo: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('GROUP', { id: this.props.params.id }));
      this.context.router.history.push('/');
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
    const { signedIn } = this.context.identity;

    dispatch(fetchGroup(id));
    dispatch(expandGroupTimeline(id));

    if (signedIn) {
      this.disconnect = dispatch(connectGroupStream(id));
    }
  }

  componentWillReceiveProps (nextProps) {
    const { dispatch } = this.props;
    const { id } = nextProps.params;
    const { signedIn } = this.context.identity;

    if (id !== this.props.params.id) {
      if (this.disconnect) {
        this.disconnect();
        this.disconnect = null;
      }

      dispatch(fetchGroup(id));
      dispatch(expandGroupTimeline(id));

      if (signedIn) {
        this.disconnect = dispatch(connectGroupStream(id));
      }
    }
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

  handleLoadMore = maxId => {
    const { id } = this.props.params;
    this.props.dispatch(expandGroupTimeline(id, { maxId }));
  }

  handleToggleGroupInfoClick = (e) => {
    const { params, columnId, showGroupInfo, dispatch } = this.props;
    e.stopPropagation();

    if (columnId) {
      dispatch(changeColumnParams(columnId, ['showGroupInfo'], !showGroupInfo));
    } else {
      dispatch(changeSetting(['groups', params.id, 'showGroupInfo'], !showGroupInfo));
    }
  }

  render () {
    const { hasUnread, columnId, multiColumn, group, showGroupInfo, intl } = this.props;
    const { id } = this.props.params;
    const pinned = !!columnId;
    const title  = group ? group.get('title') : id;

    if (typeof group === 'undefined') {
      return (
        <Column>
          <div className='scrollable'>
            <LoadingIndicator />
          </div>
        </Column>
      );
    } else if (group === false) {
      return (
        <Column>
          <ColumnBackButton multiColumn={multiColumn} />
          <MissingIndicator />
        </Column>
      );
    }

    const groupInfoButton = (
      <button
        className={classNames('column-header__button', { 'active': showGroupInfo })}
        title={intl.formatMessage(showGroupInfo ? messages.hide_group_info : messages.show_group_info)}
        aria-label={intl.formatMessage(showGroupInfo ? messages.hide_group_info : messages.show_group_info)}
        aria-pressed={showGroupInfo ? 'true' : 'false'}
        onClick={this.handleToggleGroupInfoClick}
      >
        <Icon id='info-circle' fixedWidth className='column-header__icon' />
      </button>
    );
    const groupInfo = (
      <GroupHeaderContainer
        group={group}
      />
    );

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={title}>
        <ColumnHeader
          icon='users'
          active={hasUnread}
          title={title}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
          extraButton={groupInfoButton}
          appendContent={showGroupInfo && groupInfo}
        />

        <StatusListContainer
          trackScroll={!pinned}
          scrollKey={`group_timeline-${columnId}`}
          timelineId={`group:${id}`}
          onLoadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.group' defaultMessage='There is no post in this group yet.' />}
          bindToDocument={!multiColumn}
        />
      </Column>
    );
  }

}
