import type React from 'react';
import { useCallback, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import { revealAccount } from '@/mastodon/actions/accounts_typed';
import type { ApiQuoteState } from '@/mastodon/api_types/quotes';
import { useToggle } from '@/mastodon/hooks/useToggle';
import type {
  ExpandedStatusShape,
  QuotedStatus,
} from '@/mastodon/models/status';
import {
  getAccountHidden as selectAccountHidden,
  selectPlainAccount,
} from '@/mastodon/selectors/accounts';
import { selectStatusLoadingState } from '@/mastodon/selectors/statuses';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { Button } from '../button/redesign';
import { Card, CardBody } from '../card';
import { PopoverMenuCard } from '../menu/card';

import { StatusRedesign } from './status';
import classes from './styles.module.scss';

export const StatusQuote: React.FC<QuotedStatus & { parentId: string }> = ({
  quoted_status: quotedId,
  state: quoteState,
  // parentId,
}) => {
  const { state: loadingState, status: quote } = useAppSelector((state) =>
    selectStatusLoadingState(state, { statusId: quotedId }),
  );

  const quoteError = useQuoteError({
    quoteState,
    loadingState,
    quote,
  });

  if (quoteError) {
    return (
      <Card>
        <CardBody className={classes.quoteError} noClamp>
          {quoteError}
        </CardBody>
      </Card>
    );
  }

  return (
    <Card>
      <CardBody className={classes.quoteBody}>
        <StatusRedesign id={quotedId} variant='page' />
      </CardBody>
    </Card>
  );
};

function useQuoteError({
  quote,
  loadingState,
  quoteState,
}: {
  quote?: ExpandedStatusShape | null;
  loadingState: string;
  quoteState: ApiQuoteState;
}) {
  const accountId = quote?.account.id;
  const account = useAppSelector((state) =>
    selectPlainAccount(state, accountId),
  );
  const quoteAuthorName = account?.acct;
  const domain = quoteAuthorName?.split('@')[1];
  const dispatch = useAppDispatch();
  const onRevealAccount = useCallback(() => {
    if (accountId) {
      dispatch(revealAccount({ id: accountId }));
    }
  }, [dispatch, accountId]);

  const hiddenAccount = useAppSelector(
    (state) => accountId && selectAccountHidden(state, accountId),
  );

  let message: React.ReactNode = null;
  let action: VoidFunction | null = null;
  const [reference, setReference] = useState<HTMLButtonElement | null>(null);
  const [revealed, { onTrue: onRevealQuote }] = useToggle();
  const [showInfo, { onFalse: onHideInfo, onToggle: onInfoToggle }] =
    useToggle();

  if (quoteState === 'pending') {
    return (
      <>
        <FormattedMessage
          id='status.quote_error.pending_approval'
          defaultMessage='Post pending'
        />

        <Button
          size='xs'
          variant='ghost'
          onClick={onInfoToggle}
          ref={setReference}
          aria-expanded={showInfo}
        >
          <FormattedMessage
            id='learn_more_link.learn_more'
            defaultMessage='Learn more'
          />
        </Button>

        <PopoverMenuCard
          reference={reference}
          onClose={onHideInfo}
          isOpen={showInfo}
          maxWidth={200}
          className={classes.quoteInfoPopup}
          placement='bottom-end'
        >
          <FormattedMessage
            id='status.quote_error.pending_approval_popout.body'
            defaultMessage="On Mastodon, you can control whether someone can quote you. This post is pending while we're getting the original author's approval."
            tagName='p'
          />
        </PopoverMenuCard>
      </>
    );
  }

  if (loadingState === 'filtered') {
    message = (
      <FormattedMessage
        id='status.quote_error.filtered'
        defaultMessage='Hidden due to one of your filters'
      />
    );
  } else if (quoteState === 'revoked') {
    message = (
      <FormattedMessage
        id='status.quote_error.revoked'
        defaultMessage='Post removed by author'
      />
    );
  } else if (
    (quoteState === 'blocked_account' ||
      quoteState === 'blocked_domain' ||
      quoteState === 'muted_account') &&
    !revealed &&
    accountId
  ) {
    action = onRevealQuote;

    switch (quoteState) {
      case 'blocked_account':
        message = (
          <FormattedMessage
            id='status.quote_error.blocked_account_hint.title'
            defaultMessage="This post is hidden because you've blocked @{name}."
            values={{ name: quoteAuthorName }}
          />
        );
        break;
      case 'blocked_domain':
        message = (
          <FormattedMessage
            id='status.quote_error.blocked_domain_hint.title'
            defaultMessage="This post is hidden because you've blocked {domain}."
            values={{ domain }}
          />
        );
        break;
      case 'muted_account':
        message = (
          <FormattedMessage
            id='status.quote_error.muted_account_hint.title'
            defaultMessage="This post is hidden because you've muted @{name}."
            values={{ name: quoteAuthorName }}
          />
        );
    }
  } else if (
    !quote?.id ||
    quoteState === 'deleted' ||
    quoteState === 'rejected' ||
    quoteState === 'unauthorized'
  ) {
    message = (
      <FormattedMessage
        id='status.quote_error.not_available'
        defaultMessage='Post unavailable'
      />
    );
  } else if (hiddenAccount && accountId) {
    action = onRevealAccount;
    message = (
      <FormattedMessage
        id='status.quote_error.limited_account_hint.title'
        defaultMessage='This account has been hidden by the moderators of {domain}.'
        values={{ domain }}
      />
    );
  }

  if (!message) {
    return null;
  }

  return (
    <>
      {message}

      {action && (
        <Button size='xs' variant='ghost' onClick={action}>
          <FormattedMessage
            id='status.quote_error.limited_account_hint.action'
            defaultMessage='Show anyway'
          />
        </Button>
      )}
    </>
  );
}
