import type React from 'react';

import { useAppSelector } from '@/mastodon/store';

import { ComposePoll } from './poll';
import {
  selectComposeAttachments,
  selectComposeHasAttachments,
} from './selectors';
import classes from './styles.module.scss';
import { ComposeUpload } from './upload';

export const ComposeAttachments: React.FC = () => {
  const { hasPoll, hasAttachments, quotedStatusId } = useAppSelector(
    selectComposeHasAttachments,
  );

  if (!hasPoll && !hasAttachments && !quotedStatusId) {
    return null;
  }

  return (
    <>
      {hasPoll && <ComposePoll />}
      {hasAttachments && <ComposeMediaAttachments />}
      {quotedStatusId && <ComposeQuotedStatus id={quotedStatusId} />}
    </>
  );
};

const ComposeMediaAttachments: React.FC = () => {
  const attachments = useAppSelector(selectComposeAttachments);
  const pendingAttachments = useAppSelector((state) =>
    Number(state.compose.get('pending_media_attachments')),
  );
  const totalAttachments = attachments.length + pendingAttachments;

  if (totalAttachments === 1) {
    return (
      <div className={classes.mediaSingle}>
        <ComposeUpload id={attachments.at(0)?.id} />
      </div>
    );
  }

  return (
    <div className={classes.mediaGrid} data-number={totalAttachments}>
      {attachments.map(({ id }) => (
        <ComposeUpload key={id} id={id} />
      ))}
      {[...Array(pendingAttachments).keys()].map((_, index) => (
        <ComposeUpload key={index} className={classes.mediaUploadPending} />
      ))}
    </div>
  );
};

const ComposeQuotedStatus: React.FC<{ id: string }> = ({ id }) => {
  return <div>Quoting status {id}</div>;
};
