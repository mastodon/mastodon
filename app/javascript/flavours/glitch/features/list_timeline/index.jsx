import PropTypes from 'prop-types';
import React from 'react';
import { Helmet } from 'react-helmet';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';
import { connect } from 'react-redux';
import { addColumn, removeColumn, moveColumn } from 'flavours/glitch/actions/columns';
import { fetchList, deleteList, updateList } from 'flavours/glitch/actions/lists';
import { openModal } from 'flavours/glitch/actions/modal';
import { connectListStream } from 'flavours/glitch/actions/streaming';
import { expandListTimeline } from 'flavours/glitch/actions/timelines';
import Column from 'flavours/glitch/components/column';
import ColumnBackButton from 'flavours/glitch/components/column_back_button';
import ColumnHeader from 'flavours/glitch/components/column_header';
import Icon from 'flavours/glitch/components/icon';
import LoadingIndicator from 'flavours/glitch/components/loading_indicator';
import MissingIndicator from 'flavours/glitch/components/missing_indicator';
import RadioButton from 'flavours/glitch/components/radio_button';
import StatusListContainer from 'flavours/glitch/features/ui/containers/status_list_container';

const messages = defineMessages({
  deleteMessage: { id: 'confirmations.delete_list.message', defaultMessage: 'Are you sure you want to permanently delete this list?' },
  deleteConfirm: { id: 'confirmations.delete_list.confirm', defaultMessage: 'Delete' },
  followed:   { id: 'lists.replies_policy.followed', defaultMessage: 'Any followed user' },
  none:    { id: 'lists.replies_policy.none', defaultMessage: 'No one' },
  list:  { id: 'lists.replies_policy.list', defaultMessage: 'Members of the list' },
});

const mapStateToProps = (state, props) => ({
  list: state.getIn(['lists', props.params.id]),
  hasUnread: state.getIn(['timelines', `list:${props.params.id}`, 'unread']) > 0,
});

class ListTimeline extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    columnId: PropTypes.string,
    hasUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
    list: PropTypes.oneOfType([ImmutablePropTypes.map, PropTypes.bool]),
    intl: PropTypes.object.isRequired,
  };

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('LIST', { id: this.props.params.id }));
      this.context.router.history.push('/');
    }
  };

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

  componentDidMount () {
    const { dispatch } = this.props;
    const { id } = this.props.params;

    dispatch(fetchList(id));
    dispatch(expandListTimeline(id));

    this.disconnect = dispatch(connectListStream(id));
  }

  componentWillReceiveProps (nextProps) {
    const { dispatch } = this.props;
    const { id } = nextProps.params;

    if (id !== this.props.params.id) {
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

  setRef = c => {
    this.column = c;
  };

  handleLoadMore = maxId => {
    const { id } = this.props.params;
    this.props.dispatch(expandListTimeline(id, { maxId }));
  };

  handleEditClick = () => {
    this.props.dispatch(openModal('LIST_EDITOR', { listId: this.props.params.id }));
  };

  handleDeleteClick = () => {
    const { dispatch, columnId, intl } = this.props;
    const { id } = this.props.params;

    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.deleteMessage),
      confirm: intl.formatMessage(messages.deleteConfirm),
      onConfirm: () => {
        dispatch(deleteList(id));

        if (columnId) {
          dispatch(removeColumn(columnId));
        } else {
          this.context.router.history.push('/lists');
        }
      },
    }));
  };

  handleRepliesPolicyChange = ({ target }) => {
    const { dispatch, list } = this.props;
    const { id } = this.props.params;
    this.props.dispatch(updateList(id, undefined, false, target.value));
  };

  render () {
    const { hasUnread, columnId, multiColumn, list, intl } = this.props;
    const { id } = this.props.params;
    const pinned = !!columnId;
    const title  = list ? list.get('title') : id;
    const replies_policy = list ? list.get('replies_policy') : undefined;

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
        <Column>
          <div className='scrollable'>
            <MissingIndicator />
          </div>
        </Column>
      );
    }

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={title}>
        <ColumnHeader
          icon='list-ul'
          active={hasUnread}
          title={title}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
        >
          <div className='column-settings__row column-header__links'>
            <button className='text-btn column-header__setting-btn' tabIndex={0} onClick={this.handleEditClick}>
              <Icon id='pencil' /> <FormattedMessage id='lists.edit' defaultMessage='Edit list' />
            </button>

            <button className='text-btn column-header__setting-btn' tabIndex={0} onClick={this.handleDeleteClick}>
              <Icon id='trash' /> <FormattedMessage id='lists.delete' defaultMessage='Delete list' />
            </button>
          </div>

          { replies_policy !== undefined && (
            <div role='group' aria-labelledby={`list-${id}-replies-policy`}>
              <span id={`list-${id}-replies-policy`} className='column-settings__section'>
                <FormattedMessage id='lists.replies_policy.title' defaultMessage='Show replies to:' />
              </span>
              <div className='column-settings__row'>
                { ['none', 'list', 'followed'].map(policy => (
                  <RadioButton name='order' key={policy} value={policy} label={intl.formatMessage(messages[policy])} checked={replies_policy === policy} onChange={this.handleRepliesPolicyChange} />
                ))}
              </div>
            </div>
          )}

          <hr />
        </ColumnHeader>

        <StatusListContainer
          trackScroll={!pinned}
          scrollKey={`list_timeline-${columnId}`}
          timelineId={`list:${id}`}
          onLoadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.list' defaultMessage='There is nothing in this list yet.' />}
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

export default connect(mapStateToProps)(injectIntl(ListTimeline));
