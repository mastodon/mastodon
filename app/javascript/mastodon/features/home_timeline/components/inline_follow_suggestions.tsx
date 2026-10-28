import { useEffect, useCallback, useId } from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import { Link } from 'react-router-dom';

import {
  CaretLeftIcon,
  CaretRightIcon,
  InfoIcon,
  XIcon,
} from '@phosphor-icons/react';

import { Button, IconButton } from '@/mastodon/components/button/redesign';
import { useOverflowScroll } from '@/mastodon/hooks/useOverflow';
import { changeSetting } from 'mastodon/actions/settings';
import {
  fetchSuggestions,
  dismissSuggestion,
} from 'mastodon/actions/suggestions';
import type { ApiSuggestionSourceJSON } from 'mastodon/api_types/suggestions';
import { Avatar } from 'mastodon/components/avatar';
import { Badge, VerifiedBadge } from 'mastodon/components/badge';
import { DisplayName } from 'mastodon/components/display_name';
import { FollowButton } from 'mastodon/components/follow_button';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { domain } from 'mastodon/initial_state';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  previous: { id: 'lightbox.previous', defaultMessage: 'Previous' },
  next: { id: 'lightbox.next', defaultMessage: 'Next' },
  dismiss: {
    id: 'follow_suggestions.dismiss',
    defaultMessage: "Don't show again",
  },
  friendsOfFriendsHint: {
    id: 'follow_suggestions.hints.friends_of_friends',
    defaultMessage: 'This profile is popular among the people you follow.',
  },
  similarToRecentlyFollowedHint: {
    id: 'follow_suggestions.hints.similar_to_recently_followed',
    defaultMessage:
      'This profile is similar to the profiles you have most recently followed.',
  },
  featuredHint: {
    id: 'follow_suggestions.hints.featured',
    defaultMessage: 'This profile has been hand-picked by the {domain} team.',
  },
  mostFollowedHint: {
    id: 'follow_suggestions.hints.most_followed',
    defaultMessage: 'This profile is one of the most followed on {domain}.',
  },
  mostInteractionsHint: {
    id: 'follow_suggestions.hints.most_interactions',
    defaultMessage:
      'This profile has been recently getting a lot of attention on {domain}.',
  },
});

const Source: React.FC<{ id: ApiSuggestionSourceJSON }> = ({ id }) => {
  const intl = useIntl();

  let label, hint;

  switch (id) {
    case 'friends_of_friends':
      hint = intl.formatMessage(messages.friendsOfFriendsHint);
      label = (
        <FormattedMessage
          id='follow_suggestions.personalized_suggestion'
          defaultMessage='Personalized suggestion'
        />
      );
      break;
    case 'similar_to_recently_followed':
      hint = intl.formatMessage(messages.similarToRecentlyFollowedHint);
      label = (
        <FormattedMessage
          id='follow_suggestions.personalized_suggestion'
          defaultMessage='Personalized suggestion'
        />
      );
      break;
    case 'featured':
      hint = intl.formatMessage(messages.featuredHint, { domain });
      label = (
        <FormattedMessage
          id='follow_suggestions.curated_suggestion'
          defaultMessage='Staff pick'
        />
      );
      break;
    case 'most_followed':
      hint = intl.formatMessage(messages.mostFollowedHint, { domain });
      label = (
        <FormattedMessage
          id='follow_suggestions.popular_suggestion'
          defaultMessage='Popular suggestion'
        />
      );
      break;
    case 'most_interactions':
      hint = intl.formatMessage(messages.mostInteractionsHint, { domain });
      label = (
        <FormattedMessage
          id='follow_suggestions.popular_suggestion'
          defaultMessage='Popular suggestion'
        />
      );
      break;
  }

  return (
    <Badge
      className='inline-follow-suggestions__body__scrollable__card__text-stack__source'
      title={hint}
      label={label}
      icon={<InfoIcon />}
    />
  );
};

const Card: React.FC<{
  id: string;
  sources: [ApiSuggestionSourceJSON, ...ApiSuggestionSourceJSON[]];
}> = ({ id, sources }) => {
  const intl = useIntl();
  const account = useAppSelector((state) => state.accounts.get(id));
  const firstVerifiedField = account?.fields.find((item) => !!item.verified_at);
  const dispatch = useAppDispatch();

  const handleDismiss = useCallback(() => {
    void dispatch(dismissSuggestion({ accountId: id }));
  }, [id, dispatch]);

  return (
    <div className='inline-follow-suggestions__body__scrollable__card'>
      <IconButton
        icon={XIcon}
        onClick={handleDismiss}
        className='inline-follow-suggestions__body__scrollable__card__close-button'
        size='sm'
        variant='ghost'
      >
        {intl.formatMessage(messages.dismiss)}
      </IconButton>

      <div className='inline-follow-suggestions__body__scrollable__card__avatar'>
        <Link
          to={{
            pathname: `/@${account?.acct}`,
            state: { reference: 'inline_suggestions' },
          }}
          data-hover-card-account={account?.id}
          data-hover-card-reference='inline_suggestions'
        >
          <Avatar account={account} size={70} />
        </Link>
      </div>

      <div className='inline-follow-suggestions__body__scrollable__card__text-stack'>
        <Link
          to={{
            pathname: `/@${account?.acct}`,
            state: { reference: 'inline_suggestions' },
          }}
          data-hover-card-account={account?.id}
          data-hover-card-reference='inline_suggestions'
        >
          <DisplayName account={account} />
        </Link>
        {firstVerifiedField ? (
          <VerifiedBadge link={firstVerifiedField.value} />
        ) : (
          <Source id={sources[0]} />
        )}
      </div>

      <FollowButton accountId={id} reference='inline_suggestions' />
    </div>
  );
};

const DISMISSIBLE_ID = 'home/follow-suggestions';

export const InlineFollowSuggestions: React.FC<{ hidden?: boolean }> = ({
  hidden,
}) => {
  const intl = useIntl();
  const uniqueId = useId();
  const dispatch = useAppDispatch();
  const suggestions = useAppSelector((state) => state.suggestions.items);
  const isLoading = useAppSelector((state) => state.suggestions.isLoading);
  const dismissed = useAppSelector(
    (state) => !!state.settings.getIn(['dismissed_banners', DISMISSIBLE_ID]),
  );

  useEffect(() => {
    void dispatch(fetchSuggestions());
  }, [dispatch]);

  const handleDismiss = useCallback(() => {
    dispatch(changeSetting(['dismissed_banners', DISMISSIBLE_ID], true));
  }, [dispatch]);

  const {
    bodyRef,
    handleScroll,
    canScrollLeft,
    canScrollRight,
    handleLeftNav,
    handleRightNav,
  } = useOverflowScroll({ absoluteDistance: true });

  if (dismissed || (!isLoading && suggestions.length === 0)) {
    return null;
  }

  if (hidden) {
    return <div className='inline-follow-suggestions focusable' />;
  }

  return (
    <div
      role='group'
      aria-labelledby={uniqueId}
      className='inline-follow-suggestions focusable'
      tabIndex={-1}
    >
      <div className='inline-follow-suggestions__inner'>
        <div className='inline-follow-suggestions__header'>
          <h2 id={uniqueId} className='inline-follow-suggestions__title'>
            <FormattedMessage
              id='follow_suggestions.who_to_follow'
              defaultMessage='Who to follow'
            />
          </h2>

          <div className='inline-follow-suggestions__header__actions'>
            <Button
              size='xs'
              color='accent'
              variant='ghost'
              onClick={handleDismiss}
            >
              <FormattedMessage
                id='follow_suggestions.dismiss'
                defaultMessage="Don't show again"
              />
            </Button>
            <Button
              size='xs'
              color='accent'
              variant='ghost'
              as='link'
              to='/explore/suggestions'
            >
              <FormattedMessage
                id='follow_suggestions.view_all'
                defaultMessage='View all'
              />
            </Button>
          </div>
        </div>

        <div className='inline-follow-suggestions__body'>
          <div
            className='inline-follow-suggestions__body__scrollable'
            ref={bodyRef}
            onScroll={handleScroll}
          >
            {isLoading ? (
              <LoadingIndicator />
            ) : (
              suggestions.map((suggestion) => (
                <Card
                  key={suggestion.account_id}
                  id={suggestion.account_id}
                  sources={suggestion.sources}
                />
              ))
            )}
          </div>

          {canScrollLeft && (
            <div className='inline-follow-suggestions__body__scroll-button left'>
              <IconButton
                onClick={handleLeftNav}
                icon={CaretLeftIcon}
                variant='solid'
                color='accent'
              >
                {intl.formatMessage(messages.previous)}
              </IconButton>
            </div>
          )}

          {canScrollRight && (
            <div className='inline-follow-suggestions__body__scroll-button right'>
              <IconButton
                onClick={handleRightNav}
                icon={CaretRightIcon}
                variant='solid'
                color='accent'
              >
                {intl.formatMessage(messages.next)}
              </IconButton>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
