import type { KeyboardEventHandler } from 'react';
import { useCallback, useMemo, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import { animated, useSpring } from '@react-spring/web';
import escapeTextContentForBrowser from 'escape-html';

import { EmojiHTML } from '@/mastodon/components/emoji/html';
import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import { openModal } from 'mastodon/actions/modal';
import { fetchPoll, vote } from 'mastodon/actions/polls';
import { Icon } from 'mastodon/components/icon';
import { useIdentity } from 'mastodon/identity_context';
import type * as Model from 'mastodon/models/poll';
import type { Status } from 'mastodon/models/status';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { RelativeTimestamp } from './relative_timestamp';

const messages = defineMessages({
  closed: {
    id: 'poll.closed',
    defaultMessage: 'Closed',
  },
  voted: {
    id: 'poll.voted',
    defaultMessage: 'You voted for this answer',
  },
  votes: {
    id: 'poll.votes',
    defaultMessage: '{votes, plural, one {# vote} other {# votes}}',
  },
});

const isPollExpired = (expiresAt: Model.Poll['expires_at']) =>
  new Date(expiresAt).getTime() < Date.now();

interface PollProps {
  pollId: string;
  status: Status;
  lang?: string;
  disabled?: boolean;
}

export const Poll: React.FC<PollProps> = ({ pollId, disabled, status }) => {
  // Third party hooks
  const poll = useAppSelector((state) => state.polls[pollId]);
  const identity = useIdentity();
  const intl = useIntl();
  const dispatch = useAppDispatch();

  // State
  const [revealed, setRevealed] = useState(false);
  const [selected, setSelected] = useState<Record<string, boolean>>({});

  // Derived values
  const expired = useMemo(() => {
    if (!poll) {
      return false;
    }
    return poll.expired || isPollExpired(poll.expires_at);
  }, [poll]);
  const timeRemaining = useMemo(() => {
    if (!poll) {
      return null;
    }
    if (expired) {
      return intl.formatMessage(messages.closed);
    }
    return <RelativeTimestamp timestamp={poll.expires_at} futureDate />;
  }, [expired, intl, poll]);
  const votesCount = useMemo(() => {
    if (!poll) {
      return null;
    }
    if (poll.voters_count) {
      return (
        <FormattedMessage
          id='poll.total_people'
          defaultMessage='{count, plural, one {# person} other {# people}}'
          values={{ count: poll.voters_count }}
        />
      );
    }
    return (
      <FormattedMessage
        id='poll.total_votes'
        defaultMessage='{count, plural, one {# vote} other {# votes}}'
        values={{ count: poll.votes_count }}
      />
    );
  }, [poll]);

  const voteDisabled =
    disabled || Object.values(selected).every((item) => !item);

  // Event handlers
  const handleVote = useCallback(() => {
    if (voteDisabled) {
      return;
    }

    if (identity.signedIn) {
      void dispatch(vote({ pollId, choices: Object.keys(selected) }));
    } else {
      dispatch(
        openModal({
          modalType: 'INTERACTION',
          modalProps: {
            accountId: status.getIn(['account', 'id']),
            url: status.get('uri'),
          },
        }),
      );
    }
  }, [voteDisabled, dispatch, identity, pollId, selected, status]);

  const handleReveal = useCallback(() => {
    setRevealed(true);
  }, []);

  const handleRefresh = useCallback(() => {
    if (disabled) {
      return;
    }
    void dispatch(fetchPoll({ pollId }));
  }, [disabled, dispatch, pollId]);

  const handleOptionChange = useCallback(
    (choiceIndex: number) => {
      if (!poll) {
        return;
      }
      if (poll.multiple) {
        setSelected((prev) => ({
          ...prev,
          [choiceIndex]: !prev[choiceIndex],
        }));
      } else {
        setSelected({ [choiceIndex]: true });
      }
    },
    [poll],
  );

  if (!poll) {
    return null;
  }
  const showResults = poll.voted || revealed || expired;

  return (
    <div className='poll'>
      <ul>
        {poll.options.map((option, i) => (
          <PollOption
            key={option.title || i}
            index={i}
            poll={poll}
            option={option}
            showResults={showResults}
            active={!!selected[i]}
            onChange={handleOptionChange}
          />
        ))}
      </ul>

      <div className='poll__footer'>
        {!showResults && (
          <button
            className='button button-secondary'
            disabled={voteDisabled}
            onClick={handleVote}
            type='button'
          >
            <FormattedMessage id='poll.vote' defaultMessage='Vote' />
          </button>
        )}
        {!showResults && (
          <>
            <button className='poll__link' onClick={handleReveal} type='button'>
              <FormattedMessage id='poll.reveal' defaultMessage='See results' />
            </button>{' '}
            ·{' '}
          </>
        )}
        {showResults && !disabled && (
          <>
            <button
              className='poll__link'
              onClick={handleRefresh}
              type='button'
            >
              <FormattedMessage id='poll.refresh' defaultMessage='Refresh' />
            </button>{' '}
            ·{' '}
          </>
        )}
        {votesCount}
        {poll.expires_at && <> · {timeRemaining}</>}
      </div>
    </div>
  );
};

type PollOptionProps = Pick<PollProps, 'disabled' | 'lang'> & {
  active: boolean;
  onChange: (index: number) => void;
  poll: Model.Poll;
  option: Model.PollOption;
  index: number;
  showResults?: boolean;
};

const PollOption: React.FC<PollOptionProps> = (props) => {
  const { active, lang, disabled, poll, option, index, showResults, onChange } =
    props;
  const voted = option.voted || poll.own_votes?.includes(index);
  const title = option.translation?.title ?? option.title;

  const intl = useIntl();

  // Derived values
  const percent = useMemo(() => {
    const pollVotesCount = poll.voters_count ?? poll.votes_count;
    return pollVotesCount === 0
      ? 0
      : (option.votes_count / pollVotesCount) * 100;
  }, [option, poll]);
  const isLeading = useMemo(
    () =>
      poll.options
        .filter((other) => other.title !== option.title)
        .every((other) => option.votes_count >= other.votes_count),
    [poll, option],
  );
  const titleHtml = useMemo(() => {
    let titleHtml = option.translation?.titleHtml ?? option.titleHtml;

    if (!titleHtml) {
      titleHtml = escapeTextContentForBrowser(title);
    }

    return titleHtml;
  }, [option, title]);

  // Handlers
  const handleOptionChange = useCallback(() => {
    onChange(index);
  }, [index, onChange]);
  const handleOptionKeyPress: KeyboardEventHandler = useCallback(
    (event) => {
      if (event.key === 'Enter' || event.key === ' ') {
        onChange(index);
        event.stopPropagation();
        event.preventDefault();
      }
    },
    [index, onChange],
  );

  const widthSpring = useSpring({
    from: {
      width: '0%',
    },
    to: {
      width: `${percent}%`,
    },
  });

  return (
    <li>
      <label
        className={classNames('poll__option', { selectable: !showResults })}
      >
        <input
          name='vote-options'
          type={poll.multiple ? 'checkbox' : 'radio'}
          value={index}
          checked={active}
          onChange={handleOptionChange}
          disabled={disabled}
        />

        {!showResults && (
          <span
            className={classNames('poll__input', {
              checkbox: poll.multiple,
              active,
            })}
            tabIndex={0}
            role={poll.multiple ? 'checkbox' : 'radio'}
            onKeyDown={handleOptionKeyPress}
            aria-checked={active}
            aria-label={title}
            lang={lang}
            data-index={index}
          />
        )}
        {showResults && (
          <span
            className='poll__number'
            title={intl.formatMessage(messages.votes, {
              votes: option.votes_count,
            })}
          >
            {Math.round(percent)}%
          </span>
        )}

        <EmojiHTML
          className='poll__option__text translate'
          lang={lang}
          htmlString={titleHtml}
          extraEmojis={poll.emojis}
        />

        {!!voted && (
          <span className='poll__voted'>
            <Icon
              id='check'
              icon={CheckIcon}
              className='poll__voted__mark'
              aria-label={intl.formatMessage(messages.voted)}
            />
          </span>
        )}
      </label>

      {showResults && (
        <animated.span
          className={classNames('poll__chart', { leading: isLeading })}
          style={widthSpring}
        />
      )}
    </li>
  );
};
