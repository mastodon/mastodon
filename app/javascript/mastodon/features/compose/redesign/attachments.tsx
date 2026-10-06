import type React from 'react';

import { StatusQuotePending } from '@/mastodon/components/status/quote';
import { useAppSelector } from '@/mastodon/store';

import classes from './attachments.module.scss';
import { ComposePoll } from './poll';
import { ComposeQuote } from './quote';
import {
  selectComposeAttachments,
  selectComposeHasAttachments,
} from './selectors';
import { ComposeUpload } from './upload';

export const ComposeAttachments: React.FC<{ className?: string }> = ({
  className,
}) => {
  const { hasPoll, hasAttachments, quotedStatusId, isFetchingLink } =
    useAppSelector(selectComposeHasAttachments);

  if (!hasPoll && !hasAttachments && !quotedStatusId && !isFetchingLink) {
    return null;
  }

  return (
    <div className={className}>
      {hasPoll && <ComposePoll />}
      {hasAttachments && <ComposeMediaAttachments />}
      {quotedStatusId && <ComposeQuote id={quotedStatusId} />}
      {!quotedStatusId && isFetchingLink && <StatusQuotePending />}
    </div>
  );
};

const ComposeMediaAttachments: React.FC = () => {
  const attachments = useAppSelector(selectComposeAttachments);
  const pendingAttachments = useAppSelector((state) =>
    Math.max(Number(state.compose.get('pending_media_attachments')), 0),
  );
  const totalAttachments = attachments.length + pendingAttachments;

  if (totalAttachments === 1) {
    return (
      <div className={classes.mediaSingle}>
        <ComposeUpload id={attachments.at(0)?.id} single />
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
