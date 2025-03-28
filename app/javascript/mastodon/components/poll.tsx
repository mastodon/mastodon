import type { KeyboardEventHandler } from 'react';
import { useCallback, useMemo, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import { animated, useSpring } from '@react-spring/web';
import escapeTextContentForBrowser from 'escape-html';
import { debounce } from 'lodash';

import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import { openModal } from 'mastodon/actions/modal';
import { fetchPoll, vote } from 'mastodon/actions/polls';
import { Icon } from 'mastodon/components/icon';
import emojify from 'mastodon/features/emoji/emoji';
import { useIdentity } from 'mastodon/identity_context';
import { reduceMotion } from 'mastodon/initial_state';
import { makeEmojiMap } from 'mastodon/models/custom_emoji';
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

interface PollProps {
  pollId: string;
  status: Status;
  lang?: string;
  disabled?: boolean;
}

export const Poll: React.FC<PollProps> = (props) => {
  const { pollId, status } = props;

  // Third party hooks
  const poll = useAppSelector((state) => state.polls.get(pollId));
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
    const expiresAt = poll.get('expires_at');
    return poll.get('expired') || new Date(expiresAt).getTime() < Date.now();
  }, [poll]);
  const timeRemaining = useMemo(() => {
    if (!poll) {
      return null;
    }
    if (expired) {
      return intl.formatMessage(messages.closed);
    }
    return <RelativeTimestamp timestamp={poll.get('expires_at')} futureDate />;
  }, [expired, intl, poll]);
  const votesCount = useMemo(() => {
    if (!poll) {
      return null;
    }
    if (poll.get('voters_count')) {
      return (
        <FormattedMessage
          id='poll.total_people'
          defaultMessage='{count, plural, one {# person} other {# people}}'
          values={{ count: poll.get('voters_count') }}
        />
      );
    }
    return (
      <FormattedMessage
        id='poll.total_votes'
        defaultMessage='{count, plural, one {# vote} other {# votes}}'
        values={{ count: poll.get('votes_count') }}
      />
    );
  }, [poll]);

  const disabled =
    props.disabled || Object.values(selected).every((item) => !item);

  // Event handlers
  const handleVote = useCallback(() => {
    if (disabled) {
      return;
    }

    if (identity.signedIn) {
      void dispatch(vote({ pollId, choices: Object.keys(selected) }));
    } else {
      dispatch(
        openModal({
          modalType: 'INTERACTION',
          modalProps: {
            type: 'vote',
            accountId: status.getIn(['account', 'id']),
            url: status.get('uri'),
          },
        }),
      );
    }
  }, [disabled, dispatch, identity, pollId, selected, status]);

  const handleReveal = useCallback(() => {
    setRevealed(true);
  }, []);

  const handleRefresh = useCallback(() => {
    if (disabled) {
      return;
    }
    debounce(
      () => {
        void dispatch(fetchPoll({ pollId }));
      },
      1000,
      { leading: true },
    );
  }, [disabled, dispatch, pollId]);

  const handleOptionChange = useCallback(
    (choiceIndex: number) => {
      if (!poll) {
        return;
      }
      if (poll.get('multiple')) {
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
  const showResults = poll.get('voted') || revealed || expired;

  return (
    <div className='poll'>
      <ul>
        {poll.get('options').map((option, i) => (
          <PollOption
            key={option.get('title') || i}
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
            disabled={disabled}
            onClick={handleVote}
          >
            <FormattedMessage id='poll.vote' defaultMessage='Vote' />
          </button>
        )}
        {!showResults && (
          <>
            <button className='poll__link' onClick={handleReveal}>
              <FormattedMessage id='poll.reveal' defaultMessage='See results' />
            </button>{' '}
            ·{' '}
          </>
        )}
        {showResults && !disabled && (
          <>
            <button className='poll__link' onClick={handleRefresh}>
              <FormattedMessage id='poll.refresh' defaultMessage='Refresh' />
            </button>{' '}
            ·{' '}
          </>
        )}
        {votesCount}
        {poll.get('expires_at') && <> · {timeRemaining}</>}
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
  const voted = option.get('voted') || poll.get('own_votes')?.includes(index);
  const title =
    (option.getIn(['translation', 'title']) as string) || option.get('title');

  const intl = useIntl();

  // Derived values
  const percent = useMemo(() => {
    const pollVotesCount = poll.get('voters_count') || poll.get('votes_count');
    return pollVotesCount === 0
      ? 0
      : (option.get('votes_count') / pollVotesCount) * 100;
  }, [option, poll]);
  const isLeading = useMemo(
    () =>
      poll
        .get('options')
        .filterNot((other) => other.get('title') === option.get('title'))
        .every(
          (other) => option.get('votes_count') >= other.get('votes_count'),
        ),
    [poll, option],
  );
  const titleHtml = useMemo(() => {
    let titleHtml =
      (option.getIn(['translation', 'titleHtml']) as string) ||
      option.get('titleHtml');

    if (!titleHtml) {
      const emojiMap = makeEmojiMap(poll.get('emojis'));
      titleHtml = emojify(escapeTextContentForBrowser(title), emojiMap);
    }

    return titleHtml;
  }, [option, poll, title]);

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
    immediate: reduceMotion,
  });

  return (
    <li>
      <label
        className={classNames('poll__option', { selectable: !showResults })}
      >
        <input
          name='vote-options'
          type={poll.get('multiple') ? 'checkbox' : 'radio'}
          value={index}
          checked={active}
          onChange={handleOptionChange}
          disabled={disabled}
        />

        {!showResults && (
          <span
            className={classNames('poll__input', {
              checkbox: poll.get('multiple'),
              active,
            })}
            tabIndex={0}
            role={poll.get('multiple') ? 'checkbox' : 'radio'}
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
              votes: option.get('votes_count'),
            })}
          >
            {Math.round(percent)}%
          </span>
        )}

        <span
          className='poll__option__text translate'
          lang={lang}
          dangerouslySetInnerHTML={{ __html: titleHtml }}
        />

        {!!voted && (
          <span className='poll__voted'>
            <Icon
              id='check'
              icon={CheckIcon}
              className='poll__voted__mark'
              title={intl.formatMessage(messages.voted)}
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
