import type React from 'react';
import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { WarningIcon } from '@phosphor-icons/react';

import { changeComposeLanguage } from '@/mastodon/actions/compose';
import { Callout } from '@/mastodon/components/callout/redesign';
import { useDismissible } from '@/mastodon/hooks/useDismissible';
import { selectAccountStatus } from '@/mastodon/selectors/statuses';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import { languageName, useLanguageGuess } from './hooks';
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

  const lang = useAppSelector(
    (state) => state.compose.get('language') as string,
  );
  const guess = useLanguageGuess();
  const isDifferentLanguage = lang && guess && lang !== guess;

  const messages: React.ReactNode[] = [];

  if (replyFollowersHandle) {
    messages.push(
      defaultWrapper(
        <FormattedMessage
          id='compose.hints.followers-reply'
          defaultMessage="You're replying to a followers-only post. People not following {user} might see your reply without the context of what you’re replying to."
          values={{ user: `@${replyFollowersHandle}` }}
        />,
        'followers-reply',
      ),
    );
  }

  const { wasDismissed } = useDismissible('compose_language_hint');
  if (isDifferentLanguage && !wasDismissed) {
    messages.push(<LanguageHint guess={guess} key='different-language' />);
  }

  if (missingAlt && count === 1) {
    messages.push(
      defaultWrapper(
        <FormattedMessage
          id='compose.hints.missing-alt'
          defaultMessage='Your attachment is missing alt text.'
        />,
        'missing-alt',
      ),
    );
  } else if (missingAlt) {
    messages.push(
      defaultWrapper(
        <FormattedMessage
          id='compose.hints.missing-alt-many'
          defaultMessage='One or more of your attachments are missing alt text.'
        />,
        'missing-alts',
      ),
    );
  }

  if (messages.length === 0) {
    return null;
  }

  return <div>{messages}</div>;
};

const defaultWrapper = (children: React.ReactNode, key: string) => (
  <Callout icon={WarningIcon} key={key}>
    {children}
  </Callout>
);

const LanguageHint: React.FC<{ guess: string }> = ({ guess }) => {
  const language = languageName(guess);

  const { wasDismissed, dismiss } = useDismissible('compose_language_hint');

  const dispatch = useAppDispatch();
  const handleChange = useCallback(() => {
    dispatch(changeComposeLanguage(guess));
  }, [dispatch, guess]);

  if (!language || wasDismissed) {
    return null;
  }

  return (
    <Callout
      icon={WarningIcon}
      actionClick={handleChange}
      actionText={
        <FormattedMessage
          id='compose.hints.language.change'
          defaultMessage='Change'
          description='Label on button to accept language change prompt'
        />
      }
      secondaryActionClick={dismiss}
      secondaryActionText={
        <FormattedMessage
          id='compose.hints.language.dismiss'
          defaultMessage='Dismiss'
          description='Label on button to dismiss language change prompt'
        />
      }
    >
      <FormattedMessage
        id='compose.hints.language'
        defaultMessage='Change this post’s language to {language}?'
        values={{ language }}
      />
    </Callout>
  );
};
