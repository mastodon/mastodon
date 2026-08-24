import type React from 'react';
import { useCallback, useId } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import { PlusIcon } from '@phosphor-icons/react';

import { changePollSettings, removePoll } from '@/mastodon/actions/compose';
import {
  addPollOption,
  deletePollOption,
  updatePollOption,
} from '@/mastodon/actions/compose_typed';
import { Button, buttonClasses } from '@/mastodon/components/button/redesign';
import {
  ToggleField,
  TextInput,
} from '@/mastodon/components/form_fields/redesign';
import { useAppSelector, useAppDispatch } from '@/mastodon/store';
import { DAY, HOUR, MINUTE } from '@/mastodon/utils/time';

import classes from './attachments.module.scss';
import { selectComposePoll } from './selectors';

const messages = defineMessages({
  option_placeholder: {
    id: 'compose_form.poll.option_placeholder',
    defaultMessage: 'Option {number}',
  },
  minutes: {
    id: 'intervals.full.minutes',
    defaultMessage: '{number, plural, one {# minute} other {# minutes}}',
  },
  hours: {
    id: 'intervals.full.hours',
    defaultMessage: '{number, plural, one {# hour} other {# hours}}',
  },
  days: {
    id: 'intervals.full.days',
    defaultMessage: '{number, plural, one {# day} other {# days}}',
  },
});

const pollDurationOptions = [
  5 * MINUTE,
  30 * MINUTE,
  HOUR,
  12 * HOUR,
  DAY,
  3 * DAY,
  7 * DAY,
];
function durationToMessage(durationMs: number) {
  if (durationMs < HOUR) {
    return { message: messages.minutes, multiplier: MINUTE };
  } else if (durationMs < DAY) {
    return { message: messages.hours, multiplier: HOUR };
  }
  return { message: messages.days, multiplier: DAY };
}

export const ComposePoll: React.FC = () => {
  const { options, maxOptions, expiresIn, multiple } =
    useAppSelector(selectComposePoll);
  const listId = useId();
  const intl = useIntl();

  const dispatch = useAppDispatch();
  const handleKeyDown = useCallback(
    (index: number, event: React.KeyboardEvent<HTMLInputElement>) => {
      const value = event.currentTarget.value;

      // Disable Enter key to avoid submitting the form.
      if (event.key === 'Enter') {
        event.preventDefault();
      }

      // Attempt to move to the next item, adding a new one if there is room and the current index has content.
      if (
        (event.key === 'Enter' || event.key === 'ArrowDown') &&
        value &&
        !focusOnIndex(listId, index + 1) &&
        index + 1 < maxOptions
      ) {
        dispatch(addPollOption());
        focusOnIndex(listId, index + 1, true);

        // Delete the previous option on backspace.
      } else if (event.key === 'Backspace' && index > 0 && !value) {
        dispatch(deletePollOption({ index }));
        focusOnIndex(listId, index - 1, true);

        // Move to the previous item with the up arrow.
      } else if (event.key === 'ArrowUp' && index > 0) {
        focusOnIndex(listId, index - 1);
      }
    },
    [dispatch, listId, maxOptions],
  );
  const handleAdd = useCallback(() => {
    dispatch(addPollOption());
  }, [dispatch]);
  const handlePollChangeMultiple: React.ChangeEventHandler<HTMLInputElement> =
    useCallback(
      (event) => {
        dispatch(changePollSettings(expiresIn, event.target.checked));
      },
      [dispatch, expiresIn],
    );
  const handleDurationChange: React.ChangeEventHandler<HTMLSelectElement> =
    useCallback(
      (event) => {
        dispatch(
          changePollSettings(Number.parseInt(event.target.value), multiple),
        );
      },
      [dispatch, multiple],
    );
  const handleDelete = useCallback(() => {
    dispatch(removePoll());
  }, [dispatch]);

  const firstItemEmpty = !options.at(0);

  return (
    <div className={classes.poll}>
      <ol id={listId}>
        {options.map((option, index) => (
          <ComposePollOption
            key={index}
            value={option}
            index={index}
            onKeyDown={handleKeyDown}
            disabled={firstItemEmpty && index > 0}
          />
        ))}
      </ol>

      {options.length < maxOptions && (
        <div className={classes.pollAddNew}>
          <Button
            variant='ghost'
            leadingIcon={PlusIcon}
            size='sm'
            onClick={handleAdd}
          >
            <FormattedMessage
              id='compose.poll.add'
              defaultMessage='Add another option'
            />
          </Button>
        </div>
      )}

      <ToggleField
        checked={multiple}
        wrapperClassName={classes.pollMultipleToggle}
        size='sm'
        onChange={handlePollChangeMultiple}
        label={
          <FormattedMessage
            id='compose.poll.multiple'
            defaultMessage='Allow multiple selections'
          />
        }
      />

      <div className={classes.pollControls}>
        <span>
          <FormattedMessage
            id='compose.poll.duration'
            defaultMessage='Duration:'
            description='Followed by current poll duration'
          />
          &nbsp;
          <select
            value={expiresIn}
            onChange={handleDurationChange}
            className={classNames(
              classes.pollDurationSelect,
              buttonClasses.base,
              buttonClasses.tonal,
              buttonClasses.neutral,
              buttonClasses.xs,
            )}
          >
            {pollDurationOptions.map((duration) => {
              const { message, multiplier } = durationToMessage(duration);
              return (
                <option key={duration} value={duration}>
                  {intl.formatMessage(message, {
                    number: duration / multiplier,
                  })}
                </option>
              );
            })}
          </select>
        </span>

        <Button
          variant='ghost'
          color='destructive'
          size='xs'
          onClick={handleDelete}
        >
          <FormattedMessage
            id='compose.poll.delete'
            defaultMessage='Delete poll'
          />
        </Button>
      </div>
    </div>
  );
};

const ComposePollOption: React.FC<{
  index: number;
  value: string;
  onKeyDown: (
    index: number,
    event: React.KeyboardEvent<HTMLInputElement>,
  ) => void;
  disabled: boolean;
}> = ({ index, value, disabled, onKeyDown }) => {
  const intl = useIntl();

  const dispatch = useAppDispatch();
  const handleChange: React.ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      dispatch(updatePollOption({ index, text: event.target.value }));
    },
    [dispatch, index],
  );
  const handleKeyDown: React.KeyboardEventHandler<HTMLInputElement> =
    useCallback(
      (event) => {
        onKeyDown(index, event);
      },
      [index, onKeyDown],
    );

  return (
    <li key={index} className={classes.pollOption}>
      <TextInput
        value={value}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
        placeholder={intl.formatMessage(messages.option_placeholder, {
          number: index + 1,
        })}
        maxLength={50}
        // eslint-disable-next-line jsx-a11y/no-autofocus
        autoFocus={index === 0}
        data-index={index}
        spellCheck
        autoComplete='off'
        disabled={disabled}
      />
    </li>
  );
};

function focusOnIndex(id: string, index: number, deferred = false) {
  // When adding options using React and Redux there is sometimes a delay which prevents focusing from working as intended.
  // By passing deferred, it ensures that the layout is recalculated correctly.
  if (deferred) {
    requestAnimationFrame(() => {
      focusOnIndex(id, index);
    });
    return true;
  }

  const element = document.querySelector<HTMLInputElement>(
    `#${id} input[data-index="${index}"]`,
  );
  element?.focus();
  return !!element;
}
