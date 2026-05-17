export const normalizeScheduledAt = scheduledAt => {
  if (!scheduledAt) {
    return null;
  }

  const date = new Date(scheduledAt);

  if (Number.isNaN(date.getTime())) {
    return scheduledAt;
  }

  return date.toISOString();
};

export const buildComposeSubmitData = ({
  state,
  status,
  spoilerText,
  media,
  mediaAttributes,
  statusId,
  visibility,
}) => {
  const scheduledAt = statusId === null ? normalizeScheduledAt(state.getIn(['compose', 'scheduled_at'])) : null;
  const data = {
    status,
    spoiler_text: spoilerText,
    in_reply_to_id: state.getIn(['compose', 'in_reply_to'], null),
    media_ids: media.map(item => item.get('id')),
    media_attributes: mediaAttributes,
    sensitive: state.getIn(['compose', 'sensitive']),
    visibility,
    poll: state.getIn(['compose', 'poll'], null),
    language: state.getIn(['compose', 'language']),
    quoted_status_id: state.getIn(['compose', 'quoted_status_id']),
    quote_approval_policy: visibility === 'private' || visibility === 'direct' ? 'nobody' : state.getIn(['compose', 'quote_policy']),
  };

  if (scheduledAt) {
    data.scheduled_at = scheduledAt;
  }

  return data;
};

export const isScheduledStatusResponse = status => (
  Boolean(status?.scheduled_at) && Object.prototype.hasOwnProperty.call(status, 'params')
);
