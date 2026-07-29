import { useAppSelector } from '@/mastodon/store';

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

  return (
    <div className={classes.mediaGrid} data-number={totalAttachments}>
      {attachments.map(({ id }) => (
        <ComposeUpload key={id} id={id} />
      ))}
      {Array(pendingAttachments).map((_, index) => (
        <div key={index}>Pending: {index}</div>
      ))}
    </div>
  );
};

const ComposePoll: React.FC = () => {
  return <div>TODO: Poll</div>;
};

const ComposeQuotedStatus: React.FC<{ id: string }> = ({ id }) => {
  return <div>Quoting status {id}</div>;
};
