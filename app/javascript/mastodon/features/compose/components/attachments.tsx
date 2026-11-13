import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { changeComposeSensitivity } from '@/mastodon/actions/compose';
import { Button } from '@/mastodon/components/button';
import { StatusImageGrid } from '@/mastodon/components/status/image';
import { StatusQuotePending } from '@/mastodon/components/status/quote';
import { attachmentAspectRatio } from '@/mastodon/components/status/utils';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import classes from './attachments.module.scss';
import { ComposePoll } from './poll';
import { ComposeQuote } from './quote';
import {
  selectComposeAttachments,
  selectComposeHasAttachments,
  selectComposeSensitive,
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
  const { mediaSensitive, sensitive } = useAppSelector(selectComposeSensitive);

  const dispatch = useAppDispatch();
  const onShowMedia = useCallback(() => {
    dispatch(changeComposeSensitivity());
  }, [dispatch]);

  return (
    <StatusImageGrid
      count={totalAttachments}
      className={classNames(
        classes.mediaRoot,
        totalAttachments === 1 && classes.mediaLockAspect,
      )}
      sensitive={mediaSensitive}
      style={
        {
          ['--aspect']:
            totalAttachments === 1
              ? attachmentAspectRatio(attachments[0])
              : undefined,
        } as React.CSSProperties
      }
    >
      {attachments.map(({ id }, index) => (
        <ComposeUpload
          key={id}
          id={id}
          showMediaControls={index === 1 || totalAttachments === 1}
          single={totalAttachments === 1}
          data-index={index}
        />
      ))}
      {[...Array(pendingAttachments).keys()].map((_, index) => (
        <ComposeUpload key={index} className={classes.mediaUploadPending} />
      ))}
      {mediaSensitive && (
        <div className={classes.mediaSpoilerShowButton}>
          {sensitive && (
            <FormattedMessage
              id='compose.sensitive.media_blur_warning'
              defaultMessage='Users will always see blurred media with a content warning. Click show media to edit alt text and rearrange images.'
              tagName='p'
            />
          )}
          <Button color='media' size='sm' onClick={onShowMedia}>
            <FormattedMessage
              id='content_warning.media.show_short'
              defaultMessage='Show media'
            />
          </Button>
        </div>
      )}
    </StatusImageGrid>
  );
};
