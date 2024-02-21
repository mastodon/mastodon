import PropTypes from 'prop-types';
import { useEffect, useCallback, useRef, useState } from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import { Link } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { useDispatch, useSelector } from 'react-redux';

import ChevronLeftIcon from '@/material-icons/400-24px/chevron_left.svg?react';
import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import InfoIcon from '@/material-icons/400-24px/info.svg?react';
import { followAccount, unfollowAccount } from 'mastodon/actions/accounts';
import { changeSetting } from 'mastodon/actions/settings';
import { fetchSuggestions, dismissSuggestion } from 'mastodon/actions/suggestions';
import { Avatar } from 'mastodon/components/avatar';
import { Button } from 'mastodon/components/button';
import { DisplayName } from 'mastodon/components/display_name';
import { Icon } from 'mastodon/components/icon';
import { IconButton } from 'mastodon/components/icon_button';
import { VerifiedBadge } from 'mastodon/components/verified_badge';
import { domain } from 'mastodon/initial_state';

const messages = defineMessages({
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  previous: { id: 'lightbox.previous', defaultMessage: 'Previous' },
  next: { id: 'lightbox.next', defaultMessage: 'Next' },
  dismiss: { id: 'follow_suggestions.dismiss', defaultMessage: "Don't show again" },
  friendsOfFriendsHint: { id: 'follow_suggestions.hints.friends_of_friends', defaultMessage: 'This profile is popular among the people you follow.' },
  similarToRecentlyFollowedHint: { id: 'follow_suggestions.hints.similar_to_recently_followed', defaultMessage: 'This profile is similar to the profiles you have most recently followed.' },
  featuredHint: { id: 'follow_suggestions.hints.featured', defaultMessage: 'This profile has been hand-picked by the {domain} team.' },
  mostFollowedHint: { id: 'follow_suggestions.hints.most_followed', defaultMessage: 'This profile is one of the most followed on {domain}.'},
  mostInteractionsHint: { id: 'follow_suggestions.hints.most_interactions', defaultMessage: 'This profile has been recently getting a lot of attention on {domain}.' },
});

const Source = ({ id }) => {
  const intl = useIntl();

  let label, hint;

  switch (id) {
  case 'friends_of_friends':
    hint = intl.formatMessage(messages.friendsOfFriendsHint);
    label = <FormattedMessage id='follow_suggestions.personalized_suggestion' defaultMessage='Personalized suggestion' />;
    break;
  case 'similar_to_recently_followed':
    hint = intl.formatMessage(messages.similarToRecentlyFollowedHint);
    label = <FormattedMessage id='follow_suggestions.personalized_suggestion' defaultMessage='Personalized suggestion' />;
    break;
  case 'featured':
    hint = intl.formatMessage(messages.featuredHint, { domain });
    label = <FormattedMessage id='follow_suggestions.curated_suggestion' defaultMessage='Staff pick' />;
    break;
  case 'most_followed':
    hint = intl.formatMessage(messages.mostFollowedHint, { domain });
    label = <FormattedMessage id='follow_suggestions.popular_suggestion' defaultMessage='Popular suggestion' />;
    break;
  case 'most_interactions':
    hint = intl.formatMessage(messages.mostInteractionsHint, { domain });
    label = <FormattedMessage id='follow_suggestions.popular_suggestion' defaultMessage='Popular suggestion' />;
    break;
  }

  return (
    <div className='inline-follow-suggestions__body__scrollable__card__text-stack__source' title={hint}>
      <Icon icon={InfoIcon} />
      {label}
    </div>
  );
};

Source.propTypes = {
  id: PropTypes.oneOf(['friends_of_friends', 'similar_to_recently_followed', 'featured', 'most_followed', 'most_interactions']),
};

const Card = ({ id, sources }) => {
  const intl = useIntl();
  const account = useSelector(state => state.getIn(['accounts', id]));
  const relationship = useSelector(state => state.getIn(['relationships', id]));
  const firstVerifiedField = account.get('fields').find(item => !!item.get('verified_at'));
  const dispatch = useDispatch();
  const following = relationship?.get('following') ?? relationship?.get('requested');

  const handleFollow = useCallback(() => {
    if (following) {
      dispatch(unfollowAccount(id));
    } else {
      dispatch(followAccount(id));
    }
  }, [id, following, dispatch]);

  const handleDismiss = useCallback(() => {
    dispatch(dismissSuggestion(id));
  }, [id, dispatch]);

  return (
    <div className='inline-follow-suggestions__body__scrollable__card'>
      <IconButton iconComponent={CloseIcon} onClick={handleDismiss} title={intl.formatMessage(messages.dismiss)} />

      <div className='inline-follow-suggestions__body__scrollable__card__avatar'>
        <Link to={`/@${account.get('acct')}`}><Avatar account={account} size={72} /></Link>
      </div>

      <div className='inline-follow-suggestions__body__scrollable__card__text-stack'>
        <Link to={`/@${account.get('acct')}`}><DisplayName account={account} /></Link>
        {firstVerifiedField ? <VerifiedBadge link={firstVerifiedField.get('value')} /> : <Source id={sources.get(0)} />}
      </div>

      <Button text={intl.formatMessage(following ? messages.unfollow : messages.follow)} secondary={following} onClick={handleFollow} />
    </div>
  );
};

Card.propTypes = {
  id: PropTypes.string.isRequired,
  sources: ImmutablePropTypes.list,
};

const DISMISSIBLE_ID = 'home/follow-suggestions';

export const InlineFollowSuggestions = ({ hidden }) => {
  const intl = useIntl();
  const dispatch = useDispatch();
  const suggestions = useSelector(state => state.getIn(['suggestions', 'items']));
  const isLoading = useSelector(state => state.getIn(['suggestions', 'isLoading']));
  const dismissed = useSelector(state => state.getIn(['settings', 'dismissed_banners', DISMISSIBLE_ID]));
  const bodyRef = useRef();
  const [canScrollLeft, setCanScrollLeft] = useState(false);
  const [canScrollRight, setCanScrollRight] = useState(true);

  useEffect(() => {
    dispatch(fetchSuggestions());
  }, [dispatch]);

  useEffect(() => {
    if (!bodyRef.current) {
      return;
    }

    setCanScrollLeft(bodyRef.current.scrollLeft > 0);
    setCanScrollRight((bodyRef.current.scrollLeft + bodyRef.current.clientWidth) < bodyRef.current.scrollWidth);
  }, [setCanScrollRight, setCanScrollLeft, bodyRef, suggestions]);

  const handleLeftNav = useCallback(() => {
    bodyRef.current.scrollLeft -= 200;
  }, [bodyRef]);

  const handleRightNav = useCallback(() => {
    bodyRef.current.scrollLeft += 200;
  }, [bodyRef]);

  const handleScroll = useCallback(() => {
    if (!bodyRef.current) {
      return;
    }

    setCanScrollLeft(bodyRef.current.scrollLeft > 0);
    setCanScrollRight((bodyRef.current.scrollLeft + bodyRef.current.clientWidth) < bodyRef.current.scrollWidth);
  }, [setCanScrollRight, setCanScrollLeft, bodyRef]);

  const handleDismiss = useCallback(() => {
    dispatch(changeSetting(['dismissed_banners', DISMISSIBLE_ID], true));
  }, [dispatch]);

  if (dismissed || (!isLoading && suggestions.isEmpty())) {
    return null;
  }

  if (hidden) {
    return (
      <div className='inline-follow-suggestions' />
    );
  }

  return (
    <div className='inline-follow-suggestions'>
      <div className='inline-follow-suggestions__header'>
        <h3><FormattedMessage id='follow_suggestions.who_to_follow' defaultMessage='Who to follow' /></h3>

        <div className='inline-follow-suggestions__header__actions'>
          <button className='link-button' onClick={handleDismiss}><FormattedMessage id='follow_suggestions.dismiss' defaultMessage="Don't show again" /></button>
          <Link to='/explore/suggestions' className='link-button'><FormattedMessage id='follow_suggestions.view_all' defaultMessage='View all' /></Link>
        </div>
      </div>

      <div className='inline-follow-suggestions__body'>
        <div className='inline-follow-suggestions__body__scrollable' ref={bodyRef} onScroll={handleScroll}>
          {suggestions.map(suggestion => (
            <Card
              key={suggestion.get('account')}
              id={suggestion.get('account')}
              sources={suggestion.get('sources')}
            />
          ))}
        </div>

        {canScrollLeft && (
          <button className='inline-follow-suggestions__body__scroll-button left' onClick={handleLeftNav} aria-label={intl.formatMessage(messages.previous)}>
            <div className='inline-follow-suggestions__body__scroll-button__icon'><Icon icon={ChevronLeftIcon} /></div>
          </button>
        )}

        {canScrollRight && (
          <button className='inline-follow-suggestions__body__scroll-button right' onClick={handleRightNav} aria-label={intl.formatMessage(messages.next)}>
            <div className='inline-follow-suggestions__body__scroll-button__icon'><Icon icon={ChevronRightIcon} /></div>
          </button>
        )}
      </div>
    </div>
  );
};

InlineFollowSuggestions.propTypes = {
  hidden: PropTypes.bool,
};
