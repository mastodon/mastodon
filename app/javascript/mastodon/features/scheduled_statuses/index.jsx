import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, FormattedMessage } from 'react-intl';

import { Helmet } from '@unhead/react/helmet';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { debounce } from 'lodash';

import QuietTimeIcon from '@/material-icons/400-24px/quiet_time.svg?react';
import { injectIntl } from '@/mastodon/components/intl';
import {
  fetchScheduledStatuses,
  expandScheduledStatuses,
  updateScheduledStatus,
  deleteScheduledStatus,
} from 'mastodon/actions/scheduled_statuses';
import { Button } from 'mastodon/components/button';
import ScrollableList from 'mastodon/components/scrollable_list';

import Column from '../ui/components/column';

const messages = defineMessages({
  heading: { id: 'column.scheduled_statuses', defaultMessage: 'Scheduled posts' },
  scheduledAt: { id: 'scheduled_statuses.scheduled_at', defaultMessage: 'Scheduled time' },
  reschedule: { id: 'scheduled_statuses.reschedule', defaultMessage: 'Reschedule' },
  cancel: { id: 'scheduled_statuses.cancel', defaultMessage: 'Cancel' },
  cancelConfirm: { id: 'scheduled_statuses.cancel_confirm', defaultMessage: 'Cancel this scheduled post?' },
  mediaAttachments: { id: 'scheduled_statuses.media_attachments', defaultMessage: '{count, plural, one {# media attachment} other {# media attachments}}' },
});

const formatDatetimeLocal = date => {
  const offset = date.getTimezoneOffset();
  const local = new Date(date.getTime() - offset * 60000);

  return local.toISOString().slice(0, 16);
};

const minScheduledAt = () => formatDatetimeLocal(new Date(Date.now() + 6 * 60 * 1000));

class ScheduledStatus extends PureComponent {

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    intl: PropTypes.object.isRequired,
    isUpdating: PropTypes.bool,
    isDeleting: PropTypes.bool,
    onUpdate: PropTypes.func.isRequired,
    onDelete: PropTypes.func.isRequired,
  };

  state = {
    scheduledAt: formatDatetimeLocal(new Date(this.props.status.get('scheduled_at'))),
  };

  componentDidUpdate (prevProps) {
    const scheduledAt = this.props.status.get('scheduled_at');

    if (scheduledAt !== prevProps.status.get('scheduled_at')) {
      this.setState({ scheduledAt: formatDatetimeLocal(new Date(scheduledAt)) });
    }
  }

  handleChangeScheduledAt = e => {
    this.setState({ scheduledAt: e.target.value });
  };

  handleUpdate = () => {
    this.props.onUpdate(this.props.status.get('id'), this.state.scheduledAt);
  };

  handleDelete = () => {
    const { intl, onDelete, status } = this.props;

    if (window.confirm(intl.formatMessage(messages.cancelConfirm))) {
      onDelete(status.get('id'));
    }
  };

  render () {
    const { intl, status, isUpdating, isDeleting } = this.props;
    const { scheduledAt } = this.state;
    const params = status.get('params');
    const text = params.get('text') || '';
    const spoilerText = params.get('spoiler_text');
    const mediaCount = status.get('media_attachments')?.size || 0;
    const hasValidSchedule = scheduledAt && new Date(scheduledAt).getTime() > Date.now() + 5 * 60 * 1000;

    return (
      <div className='scheduled-status'>
        <div className='scheduled-status__metadata'>
          <time dateTime={status.get('scheduled_at')} className='scheduled-status__date'>
            {intl.formatDate(new Date(status.get('scheduled_at')), {
              dateStyle: 'medium',
              timeStyle: 'short',
            })}
          </time>

          {mediaCount > 0 && (
            <span className='scheduled-status__media'>
              {intl.formatMessage(messages.mediaAttachments, { count: mediaCount })}
            </span>
          )}
        </div>

        {spoilerText && <div className='scheduled-status__spoiler'>{spoilerText}</div>}
        <div className='scheduled-status__content'>{text}</div>

        <div className='scheduled-status__controls'>
          <label className='scheduled-status__label' htmlFor={`scheduled-status-${status.get('id')}`}>
            {intl.formatMessage(messages.scheduledAt)}
          </label>

          <input
            id={`scheduled-status-${status.get('id')}`}
            className='scheduled-status__input'
            type='datetime-local'
            value={scheduledAt}
            min={minScheduledAt()}
            disabled={isUpdating || isDeleting}
            onChange={this.handleChangeScheduledAt}
          />

          <Button
            compact
            disabled={!hasValidSchedule || isUpdating || isDeleting}
            loading={isUpdating}
            onClick={this.handleUpdate}
          >
            {intl.formatMessage(messages.reschedule)}
          </Button>

          <Button
            compact
            dangerous
            disabled={isUpdating || isDeleting}
            loading={isDeleting}
            onClick={this.handleDelete}
          >
            {intl.formatMessage(messages.cancel)}
          </Button>
        </div>
      </div>
    );
  }

}

const ScheduledStatusItem = injectIntl(ScheduledStatus);

const mapStateToProps = state => ({
  statusIds: state.getIn(['scheduled_statuses', 'items']),
  statuses: state.getIn(['scheduled_statuses', 'statuses']),
  updating: state.getIn(['scheduled_statuses', 'updating']),
  deleting: state.getIn(['scheduled_statuses', 'deleting']),
  isLoading: state.getIn(['scheduled_statuses', 'isLoading'], true),
  hasMore: !!state.getIn(['scheduled_statuses', 'next']),
});

class ScheduledStatuses extends PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.orderedSet,
    statuses: ImmutablePropTypes.map,
    updating: ImmutablePropTypes.map,
    deleting: ImmutablePropTypes.map,
    hasMore: PropTypes.bool,
    isLoading: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  componentDidMount () {
    this.props.dispatch(fetchScheduledStatuses());
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandScheduledStatuses());
  }, 300, { leading: true });

  handleUpdate = (id, scheduledAt) => {
    this.props.dispatch(updateScheduledStatus(id, scheduledAt));
  };

  handleDelete = id => {
    this.props.dispatch(deleteScheduledStatus(id));
  };

  render () {
    const { intl, statusIds, statuses, updating, deleting, hasMore, multiColumn, isLoading } = this.props;
    const emptyMessage = <FormattedMessage id='empty_column.scheduled_statuses' defaultMessage="You don't have any scheduled posts." />;

    return (
      <Column bindToDocument={!multiColumn} icon='clock' iconComponent={QuietTimeIcon} heading={intl.formatMessage(messages.heading)} alwaysShowBackButton>
        <ScrollableList
          scrollKey='scheduled_statuses'
          onLoadMore={this.handleLoadMore}
          hasMore={hasMore}
          isLoading={isLoading}
          showLoading={isLoading && statusIds.size === 0}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
        >
          {statusIds.map(id => (
            <ScheduledStatusItem
              key={id}
              status={statuses.get(id)}
              isUpdating={updating.get(id)}
              isDeleting={deleting.get(id)}
              onUpdate={this.handleUpdate}
              onDelete={this.handleDelete}
            />
          ))}
        </ScrollableList>

        <Helmet>
          <title>{intl.formatMessage(messages.heading)}</title>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(ScheduledStatuses));
