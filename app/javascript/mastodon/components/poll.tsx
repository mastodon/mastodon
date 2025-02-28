import { useCallback, useEffect, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import { spring } from 'react-motion';

import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import { Icon } from 'mastodon/components/icon';
import Motion from 'mastodon/features/ui/util/optional_motion';
import { useIdentity } from 'mastodon/identity_context';
import type {
  Poll as PollModel,
  PollOption as PollOptionModel,
} from 'mastodon/models/poll';
import type { Status } from 'mastodon/models/status';

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

export const PollOption: React.FC<{
  option: PollOptionModel;
  optionIndex: number;
  showResults: boolean;
  percent: number;
  voted: boolean;
  leading: boolean;
  multiple: boolean;
  lang: string;
  disabled: boolean;
  active: boolean;
  toggleOption: () => void;
}> = ({
  option,
  optionIndex,
  percent,
  leading,
  voted,
  multiple,
  showResults,
  lang,
  disabled,
  active,
  toggleOption,
}) => {
  const intl = useIntl();
  const title = option.translation?.title ?? option.title;
  const titleHtml = option.translation?.titleHtml ?? option.titleHtml;

  const handleOptionKeyPress = useCallback<
    React.KeyboardEventHandler<HTMLElement>
  >(
    (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        toggleOption();
        e.stopPropagation();
        e.preventDefault();
      }
    },
    [toggleOption],
  );

  return (
    <li key={option.title}>
      <label
        className={classNames('poll__option', { selectable: !showResults })}
      >
        <input
          name='vote-options'
          type={multiple ? 'checkbox' : 'radio'}
          value={optionIndex}
          checked={active}
          onChange={toggleOption}
          disabled={disabled}
        />

        {showResults ? (
          <span
            className='poll__number'
            title={intl.formatMessage(messages.votes, {
              votes: option.votes_count,
            })}
          >
            {Math.round(percent)}%
          </span>
        ) : (
          <span
            className={classNames('poll__input', {
              checkbox: multiple,
              active,
            })}
            tabIndex={0}
            role={multiple ? 'checkbox' : 'radio'}
            onKeyPress={handleOptionKeyPress}
            aria-checked={active}
            aria-label={title}
            lang={lang}
          />
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
        <Motion
          defaultStyle={{ width: 0 }}
          style={{ width: spring(percent, { stiffness: 180, damping: 12 }) }}
        >
          {({ width }) => (
            <span
              className={classNames('poll__chart', { leading })}
              style={{ width: `${width}%` }}
            />
          )}
        </Motion>
      )}
    </li>
  );
};

export const Poll: React.FC<{
  poll: PollModel;
  status: Status;
  lang: string;
  disabled?: boolean;
  refresh?: () => void;
  onVote?: (votes: string[]) => void;
  onInteractionModal: (interactionType: string, status: Status) => void;
}> = ({
  poll,
  lang,
  disabled,
  refresh,
  onVote,
  onInteractionModal,
  status,
}) => {
  const intl = useIntl();

  const expires_at = poll.expires_at;
  const [expired, setExpired] = useState(
    poll.expired ||
      (!!expires_at && new Date(expires_at).getTime() < Date.now()),
  );

  const [revealed, setRevealed] = useState(false);

  const handleReveal = useCallback(() => {
    setRevealed(true);
  }, []);

  const [selected, setSelected] = useState<Set<string>>(new Set());

  const toggleOption = useCallback(
    (option: string) => {
      setSelected((prev) => {
        const next = new Set(prev);

        if (poll.multiple) {
          if (next.has(option)) next.delete(option);
          else next.add(option);
        } else {
          next.add(option);
        }
        return next;
      });
    },
    [poll.multiple],
  );

  const makeToggleOption = (option: string) => () => {
    toggleOption(option);
  };

  const { signedIn } = useIdentity();

  const handleRefresh = useCallback(() => {
    if (disabled) {
      return;
    }

    refresh?.();
  }, [refresh, disabled]);

  const handleVote = useCallback(() => {
    if (disabled) {
      return;
    }

    if (signedIn) {
      onVote?.(Array.from(selected));
    } else {
      onInteractionModal('vote', status);
    }
  }, [disabled, onVote, selected, signedIn, status, onInteractionModal]);

  useEffect(() => {
    if (expired || !expires_at) return () => undefined;

    const delay = new Date(expires_at).getTime() - Date.now();
    const timer = setTimeout(() => {
      setExpired(true);
    }, delay);

    return () => {
      clearTimeout(timer);
    };
  }, [expired, expires_at]);

  const timeRemaining =
    expired || !expires_at ? (
      intl.formatMessage(messages.closed)
    ) : (
      <RelativeTimestamp timestamp={expires_at} futureDate />
    );
  const showResults = poll.voted || revealed || expired;

  let votesCount = null;

  if (poll.voters_count) {
    votesCount = (
      <FormattedMessage
        id='poll.total_people'
        defaultMessage='{count, plural, one {# person} other {# people}}'
        values={{ count: poll.voters_count }}
      />
    );
  } else {
    votesCount = (
      <FormattedMessage
        id='poll.total_votes'
        defaultMessage='{count, plural, one {# vote} other {# votes}}'
        values={{ count: poll.votes_count }}
      />
    );
  }

  return (
    <div className='poll'>
      <ul>
        {poll.options.map((option, i) => {
          // eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing -- we want `votes_count` if `voters_count` is 0
          const pollVotesCount = poll.voters_count || poll.votes_count;
          const percent =
            pollVotesCount === 0
              ? 0
              : (option.votes_count / pollVotesCount) * 100;

          return (
            <PollOption
              option={option}
              optionIndex={i}
              key={option.title}
              active={selected.has(option.title)}
              showResults={showResults}
              lang={lang}
              toggleOption={makeToggleOption(option.title)}
              multiple={poll.multiple}
              voted={option.voted || poll.own_votes?.includes(i) || false}
              leading={poll.options
                .filter((other) => other.title !== option.title)
                .every((other) => option.votes_count >= other.votes_count)}
              percent={percent}
              disabled={disabled || selected.size === 0}
            />
          );
        })}
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
        {poll.expires_at && <> · {timeRemaining}</>}
      </div>
    </div>
  );
};
