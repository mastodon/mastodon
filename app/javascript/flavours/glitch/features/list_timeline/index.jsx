import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';

import { Helmet } from 'react-helmet';
import { withRouter } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import Toggle from 'react-toggle';

import DeleteIcon from '@/material-icons/400-24px/delete.svg?react';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import { addColumn, removeColumn, moveColumn } from 'flavours/glitch/actions/columns';
import { fetchList, deleteList, updateList } from 'flavours/glitch/actions/lists';
import { openModal } from 'flavours/glitch/actions/modal';
import { connectListStream } from 'flavours/glitch/actions/streaming';
import { expandListTimeline } from 'flavours/glitch/actions/timelines';
import Column from 'flavours/glitch/components/column';
import ColumnHeader from 'flavours/glitch/components/column_header';
import { Icon }  from 'flavours/glitch/components/icon';
import { LoadingIndicator } from 'flavours/glitch/components/loading_indicator';
import { RadioButton } from 'flavours/glitch/components/radio_button';
import BundleColumnError from 'flavours/glitch/features/ui/components/bundle_column_error';
import StatusListContainer from 'flavours/glitch/features/ui/containers/status_list_container';
import { WithRouterPropTypes } from 'flavours/glitch/utils/react_router';

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

  UNSAFE_componentWillReceiveProps (nextProps) {
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
    this.props.dispatch(openModal({
      modalType: 'LIST_EDITOR',
      modalProps: { listId: this.props.params.id },
    }));
  };

  handleDeleteClick = () => {
    const { dispatch, columnId, intl } = this.props;
    const { id } = this.props.params;

    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        message: intl.formatMessage(messages.deleteMessage),
        confirm: intl.formatMessage(messages.deleteConfirm),
        onConfirm: () => {
          dispatch(deleteList(id));

          if (columnId) {
            dispatch(removeColumn(columnId));
          } else {
            this.props.history.push('/lists');
          }
        },
      },
    }));
  };

  handleRepliesPolicyChange = ({ target }) => {
    const { dispatch } = this.props;
    const { id } = this.props.params;
    dispatch(updateList(id, undefined, false, undefined, target.value));
  };

  onExclusiveToggle = ({ target }) => {
    const { dispatch } = this.props;
    const { id } = this.props.params;
    dispatch(updateList(id, undefined, false, target.checked, undefined));
  };

  render () {
    const { hasUnread, columnId, multiColumn, list, intl } = this.props;
    const { id } = this.props.params;
    const pinned = !!columnId;
    const title  = list ? list.get('title') : id;
    const replies_policy = list ? list.get('replies_policy') : undefined;
    const isExclusive = list ? list.get('exclusive') : undefined;

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
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={title}>
        <ColumnHeader
          icon='list-ul'
          iconComponent={ListAltIcon}
          active={hasUnread}
          title={title}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
        >
          <div className='column-settings'>
            <section className='column-header__links'>
              <button type='button' className='text-btn column-header__setting-btn' tabIndex={0} onClick={this.handleEditClick}>
                <Icon id='pencil' icon={EditIcon} /> <FormattedMessage id='lists.edit' defaultMessage='Edit list' />
              </button>

              <button type='button' className='text-btn column-header__setting-btn' tabIndex={0} onClick={this.handleDeleteClick}>
                <Icon id='trash' icon={DeleteIcon} /> <FormattedMessage id='lists.delete' defaultMessage='Delete list' />
              </button>
            </section>

            <section>
              <div className='setting-toggle'>
                <Toggle id={`list-${id}-exclusive`} checked={isExclusive} onChange={this.onExclusiveToggle} />
                <label htmlFor={`list-${id}-exclusive`} className='setting-toggle__label'>
                  <FormattedMessage id='lists.exclusive' defaultMessage='Hide these posts from home' />
                </label>
              </div>
            </section>

            {replies_policy !== undefined && (
              <section aria-labelledby={`list-${id}-replies-policy`}>
                <h3 id={`list-${id}-replies-policy`}><FormattedMessage id='lists.replies_policy.title' defaultMessage='Show replies to:' /></h3>

                <div className='column-settings__row'>
                  { ['none', 'list', 'followed'].map(policy => (
                    <RadioButton name='order' key={policy} value={policy} label={intl.formatMessage(messages[policy])} checked={replies_policy === policy} onChange={this.handleRepliesPolicyChange} />
                  ))}
                </div>
              </section>
            )}
          </div>
        </ColumnHeader>

        <StatusListContainer
          trackScroll={!pinned}
          scrollKey={`list_timeline-${columnId}`}
          timelineId={`list:${id}`}
          onLoadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.list' defaultMessage='There is nothing in this list yet. When members of this list post new statuses, they will appear here.' />}
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

export default withRouter(connect(mapStateToProps)(injectIntl(ListTimeline)));
