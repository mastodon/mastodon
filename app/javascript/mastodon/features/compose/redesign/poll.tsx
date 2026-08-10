import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import {
  changePollSettings,
  removePoll,
  changePollOption,
} from '@/mastodon/actions/compose';
import { Button } from '@/mastodon/components/button/redesign';
import {
  ToggleField,
  TextInput,
} from '@/mastodon/components/form_fields/redesign';
import { useAppSelector, useAppDispatch } from '@/mastodon/store';

import { selectComposePoll } from './selectors';
import classes from './styles.module.scss';

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

export const ComposePoll: React.FC = () => {
  const poll = useAppSelector(selectComposePoll);

  const dispatch = useAppDispatch();
  const handlePollChangeMultiple: React.ChangeEventHandler<HTMLInputElement> =
    useCallback(
      (event) => {
        dispatch(changePollSettings(poll?.expiresIn, event.target.checked));
      },
      [dispatch, poll?.expiresIn],
    );
  const handleDelete = useCallback(() => {
    dispatch(removePoll());
  }, [dispatch]);

  if (!poll) {
    return null;
  }

  return (
    <div className={classes.poll}>
      <ol>
        {poll.options.map((option, index) => (
          <ComposePollOption key={index} value={option} index={index} />
        ))}
      </ol>

      <ToggleField
        checked={poll.multiple}
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
        <FormattedMessage
          id='compose.poll.duration'
          defaultMessage='Duration: {button}'
          values={{
            button: (
              <Button color='tonal' size='xs'>
                <FormattedMessage
                  id='intervals.full.days'
                  defaultMessage='{number, plural, one {# day} other {# days}}'
                  values={{ number: 1 }}
                />
              </Button>
            ),
          }}
          tagName='span'
        />

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

const ComposePollOption: React.FC<{ index: number; value: string }> = ({
  index,
  value,
}) => {
  const intl = useIntl();
  const maxOptions = useAppSelector(
    (state) => state.server.server.item?.configuration.polls.max_options ?? 4,
  );

  const dispatch = useAppDispatch();
  const handleChange: React.ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      dispatch(changePollOption(index, event.target.value, maxOptions));
    },
    [dispatch, index, maxOptions],
  );

  return (
    <li key={index} className={classes.pollOption}>
      <TextInput
        value={value}
        onChange={handleChange}
        placeholder={intl.formatMessage(messages.option_placeholder, {
          number: index + 1,
        })}
        maxLength={50}
        // eslint-disable-next-line jsx-a11y/no-autofocus
        autoFocus={index === 0}
        spellCheck
      />
    </li>
  );
};
