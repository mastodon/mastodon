import type React from 'react';

import { FormattedMessage } from 'react-intl';

import { WarningIcon } from '@phosphor-icons/react';

import { Callout } from '@/mastodon/components/callout/redesign';
import { selectAccountStatus } from '@/mastodon/selectors/statuses';
import { createAppSelector, useAppSelector } from '@/mastodon/store';

import { selectComposeAttachments } from './selectors';

const selectComposeAttachmentsWithoutAlt = createAppSelector(
  [selectComposeAttachments],
  (attachments) => ({
    count: attachments.length,
    missingAlt: attachments.some((attachment) => !attachment.description),
  }),
);

const selectIsFollowersReply = createAppSelector(
  [
    (state) =>
      selectAccountStatus(
        state,
        state.compose.get('in_reply_to') as null | string,
      ),
  ],
  (status) => (status?.visibility === 'private' ? status.account.acct : null),
);

export const ComposeHints = () => {
  const { count, missingAlt } = useAppSelector(
    selectComposeAttachmentsWithoutAlt,
  );
  const replyFollowersHandle = useAppSelector(selectIsFollowersReply);

  const messages: React.ReactNode[] = [];

  if (replyFollowersHandle) {
    messages.push(
      defaultCallout(
        <FormattedMessage
          id='compose.hints.followers-reply'
          defaultMessage="You're replying to a followers-only post. People not following {user} might see your reply without the context of what you’re replying to."
          values={{ user: `@${replyFollowersHandle}` }}
        />,
      ),
    );
  }

  if (missingAlt && count === 1) {
    messages.push(
      defaultCallout(
        <FormattedMessage
          id='compose.hints.missing-alt'
          defaultMessage='Your attachment is missing alt text.'
        />,
      ),
    );
  } else if (missingAlt) {
    messages.push(
      defaultCallout(
        <FormattedMessage
          id='compose.hints.missing-alt-many'
          defaultMessage='One or more of your attachments are missing alt text.'
        />,
      ),
    );
  }

  if (messages.length === 0) {
    return null;
  }

  return <div>{messages}</div>;
};

const defaultCallout = (children: React.ReactNode) => (
  <Callout icon={WarningIcon}>{children}</Callout>
);
