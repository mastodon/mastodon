import { useCallback, useEffect, useMemo, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import { Button } from 'mastodon/components/button';
import { openModal } from 'mastodon/actions/modal';
import { updateScheduledStatus } from 'mastodon/actions/scheduled_statuses';
import { messages as privacyMessages } from 'mastodon/features/compose/components/privacy_dropdown';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import {
  datetimeLocalToIso,
  getMinimumScheduledAt,
  isScheduledAtValid,
  isoToDatetimeLocal,
} from '../utils';

import classes from './scheduled_status_item.module.scss';

const messages = defineMessages({
  publishOn: {
    id: 'compose_form.publish_on',
    defaultMessage: 'Publish on',
  },
  edit: { id: 'scheduled_statuses.edit', defaultMessage: 'Edit' },
  delete: { id: 'scheduled_statuses.delete', defaultMessage: 'Delete' },
  save: { id: 'scheduled_statuses.save', defaultMessage: 'Save' },
  mediaPost: {
    id: 'scheduled_statuses.media_post',
    defaultMessage: 'Media post',
  },
  scheduledPost: {
    id: 'scheduled_statuses.scheduled_post',
    defaultMessage: 'Scheduled post',
  },
  contentWarning: {
    id: 'scheduled_statuses.content_warning',
    defaultMessage: 'Content warning: {contentWarning}',
  },
  scheduleHint: {
    id: 'compose_form.schedule_hint',
    defaultMessage: 'Pick a time at least 5 minutes ahead.',
  },
});

const visibilityMessages = {
  public: privacyMessages.public_short,
  unlisted: privacyMessages.unlisted_short,
  private: privacyMessages.private_short,
  direct: privacyMessages.direct_short,
} as const;

interface Props {
  scheduledStatus: ImmutableMap<string, unknown>;
}

export const ScheduledStatusItem: React.FC<Props> = ({ scheduledStatus }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const id = scheduledStatus.get('id') as string;
  const params = scheduledStatus.get('params', ImmutableMap()) as ImmutableMap<
    string,
    unknown
  >;
  const mediaAttachments = scheduledStatus.get(
    'media_attachments',
    ImmutableList(),
  ) as ImmutableList<ImmutableMap<string, unknown>>;
  const scheduledAt = scheduledStatus.get('scheduled_at') as string;
  const [value, setValue] = useState(() => isoToDatetimeLocal(scheduledAt));
  const isUpdating = useAppSelector(
    (state) => !!state.scheduled_statuses.getIn(['updating', id]),
  );
  const isDeleting = useAppSelector(
    (state) => !!state.scheduled_statuses.getIn(['deleting', id]),
  );

  useEffect(() => {
    setValue(isoToDatetimeLocal(scheduledAt));
  }, [scheduledAt]);

  const preview = useMemo(() => {
    const text = (params.get('text') as string | undefined)?.trim();

    if (text) {
      return text;
    }

    if (mediaAttachments.size > 0) {
      return intl.formatMessage(messages.mediaPost);
    }

    return intl.formatMessage(messages.scheduledPost);
  }, [intl, mediaAttachments.size, params]);

  const contentWarning = (params.get('spoiler_text') as string | undefined)?.trim();
  const visibility = params.get('visibility') as string | undefined;
  const visibilityKey = (
    visibility && visibility in visibilityMessages ? visibility : 'public'
  ) as keyof typeof visibilityMessages;
  const isValid = isScheduledAtValid(value);
  const nextScheduledAt = datetimeLocalToIso(value);
  const currentScheduledAt = datetimeLocalToIso(isoToDatetimeLocal(scheduledAt));
  const isDirty = nextScheduledAt !== null && nextScheduledAt !== currentScheduledAt;

  const handleSave = useCallback(() => {
    if (!nextScheduledAt || !isDirty) {
      return;
    }

    void dispatch(updateScheduledStatus(id, nextScheduledAt));
  }, [dispatch, id, isDirty, nextScheduledAt]);

  const handleChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setValue(event.target.value);
    },
    [],
  );

  const handleEdit = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'CONFIRM_SCHEDULED_STATUS',
        modalProps: {
          action: 'edit',
          scheduledStatus: scheduledStatus.toJS(),
        },
      }),
    );
  }, [dispatch, scheduledStatus]);

  const handleDelete = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'CONFIRM_SCHEDULED_STATUS',
        modalProps: {
          action: 'delete',
          scheduledStatus: scheduledStatus.toJS(),
        },
      }),
    );
  }, [dispatch, scheduledStatus]);

  return (
    <article className={classes.item}>
      <div className={classes.header}>
        <p className={classes.preview}>{preview}</p>
        <span className={classes.visibility}>
          {intl.formatMessage(visibilityMessages[visibilityKey])}
        </span>
      </div>

      {contentWarning && (
        <p className={classes.meta}>
          {intl.formatMessage(messages.contentWarning, {
            contentWarning,
          })}
        </p>
      )}

      <label className={classes.field}>
        <span className={classes.label}>
          {intl.formatMessage(messages.publishOn)}
        </span>
        <input
          className={classes.input}
          type='datetime-local'
          value={value}
          min={getMinimumScheduledAt()}
          onChange={handleChange}
          disabled={isUpdating || isDeleting}
        />
      </label>

      {!isValid && (
        <p className={classes.meta}>{intl.formatMessage(messages.scheduleHint)}</p>
      )}

      <div className={classes.actions}>
        <Button
          compact
          secondary
          onClick={handleSave}
          disabled={!isDirty || !isValid || isDeleting}
          loading={isUpdating}
        >
          {intl.formatMessage(messages.save)}
        </Button>
        <Button compact plain onClick={handleEdit} disabled={isUpdating || isDeleting}>
          {intl.formatMessage(messages.edit)}
        </Button>
        <Button
          compact
          plain
          dangerous
          onClick={handleDelete}
          disabled={isUpdating || isDeleting}
        >
          {intl.formatMessage(messages.delete)}
        </Button>
      </div>
    </article>
  );
};
